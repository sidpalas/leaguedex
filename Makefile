TAG?=0.0.1
API_IMAGE_NAME:=sidpalas/leaguedex-api:$(TAG)
CLIENT_IMAGE_NAME:=sidpalas/leaguedex-client:$(TAG)

.PHONY: build-api
build-api:
	cd server && docker build -t $(API_IMAGE_NAME) . 

.PHONY: build-dev-client
build-dev-client: build-api
	cd client && make build-base

.PHONY: build-production-client
build-production-client:
	cd client && CLIENT_IMAGE_NAME=$(CLIENT_IMAGE_NAME) make build-production-client

.PHONY: build-images
build-images:
	$(MAKE) build-api
	$(MAKE) build-production-client

.PHONY: push-api
push-api: build-api
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
	docker-compose --file docker-compose-dev.yml up --remove-orphans

.PHONY: bootstrap-db
bootstrap-db:
	docker-compose --file docker-compose-dev.yml up db bootstrap-db
	docker-compose --file docker-compose-dev.yml down

.PHONY: run-production
run-production:
	docker-compose --file docker-compose-production.yml up --remove-orphans


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
	docker-compose --file docker-compose-dev.yml up -d db
	
	sleep 15

	docker exec -i leaguedex_db_1 /bin/bash \
		-c "PGPASSWORD=postgres psql \
		--username postgres" < ./dump.sql

	docker-compose --file docker-compose-dev.yml down

# Will need to drop either the staging or production database
