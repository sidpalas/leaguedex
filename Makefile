DOCKER_TAG?=0.0.1
API_IMAGE_NAME:=sidpalas/leaguedex-api:$(DOCKER_TAG)
CLIENT_IMAGE_NAME:=sidpalas/leaguedex-client:$(DOCKER_TAG)
DROPLET_IP?=143.110.144.33

.PHONY: build-api
build-api:
	cd server && docker build -t $(API_IMAGE_NAME) . 

.PHONY: build-dev-client
build-dev-client:
	cd client && CLIENT_IMAGE_NAME=$(CLIENT_IMAGE_NAME) make build-base

.PHONY: build-dev
build-dev:
	$(MAKE) build-api
	$(MAKE) build-dev-client

.PHONY: build-production-client
build-production-client:
	cd client && CLIENT_IMAGE_NAME=$(CLIENT_IMAGE_NAME) make build-production-client

.PHONY: build-images
build-images:
	$(MAKE) build-api
	$(MAKE) build-production-client

.PHONY: push-api
push-api:
	docker push $(API_IMAGE_NAME)

.PHONY: push-client
push-client: 
	docker push $(CLIENT_IMAGE_NAME)

.PHONY: push-images
push-images:
	$(MAKE) push-api
	$(MAKE) push-client

.PHONY: run-dev
run-dev:
	DOCKER_TAG=$(DOCKER_TAG) docker-compose --file docker-compose-dev.yml up --remove-orphans

.PHONY: bootstrap-db
bootstrap-db:
	DOCKER_TAG=$(DOCKER_TAG) docker-compose --file docker-compose-dev.yml up -d db bootstrap-db
	DOCKER_TAG=$(DOCKER_TAG) docker-compose --file docker-compose-dev.yml down

.PHONY: copy-compose-file-to-droplet
copy-compose-file-to-droplet:
	ssh -l root -- $(DROPLET_IP) mkdir -p ./leaguedex
	scp docker-compose.yml root@$(DROPLET_IP):./leaguedex/docker-compose.yml

# Need to boostrap DB before we can launch app
.PHONY: bootstrap-production
bootstrap-production:
	@echo "TODO: Bootstrapping production DB"

.PHONY: run-production-local
run-production-local:
	DOCKER_TAG=$(DOCKER_TAG) \
	  DATABASE_PASSWORD=postgres \
		DATABASE_URL=postgresql://postgres:postgres@db:5432/leaguedex?schema=leaguedex \
		docker-compose \
		--env-file $(CURDIR)/server/.env \
		--file $(CURDIR)/docker-compose.yml \
		up -d --remove-orphans

.PHONY: run-production
run-production:
	ssh -l root -- $(DROPLET_IP) \
		DOCKER_TAG=$(DOCKER_TAG) \
		API_KEY=$(RIOT_API_KEY) \
		ACCESS_TOKEN_SECRET=$(AUTH_ACCESS_TOKEN_SECRET) \
		REFRESH_TOKEN_SECRET=$(AUTH_REFRESH_TOKEN_SECRET) \
		SENDGRID_API_KEY=EMAIL_DISABLED \
		SENDGRID_EMAIL=EMAIL_DISABLED \
		DATABASE_PASSWORD=$(DATABASE_PASSWORD) \
		DATABASE_URL=postgresql://postgres:$(DATABASE_PASSWORD)@db:5432/leaguedex?schema=leaguedex \
		docker-compose --file ./leaguedex/docker-compose.yml up -d --remove-orphans

###

# Will need to execute the dump command on droplet directly

# Should write a migration to rename the database and restore
# Staging and Production separately...

.PHONY: dump-db
dump-db:
	docker exec -i leaguedex_db_1 /bin/bash \
		-c "PGPASSWORD=postgres pg_dumpall \
		--username postgres" > ./dump.sql

.PHONY: restore-db
restore-db:
	DOCKER_TAG=$(DOCKER_TAG) \
		DATABASE_PASSWORD=$(DATABASE_PASSWORD) \
		docker-compose --file docker-compose.yml up -d db
	
	sleep 15

	docker exec -i leaguedex_db_1 /bin/bash \
		-c "PGPASSWORD=postgres psql \
		--username postgres" < ./dump.sql

	docker-compose --file docker-compose.yml down

# Will need to drop either the staging or production database
