TAG?=0.0.1
API_IMAGE_NAME:=sidpalas/leaguedex-api:$(TAG)
CLIENT_IMAGE_NAME:=sidpalas/leaguedex-client:$(TAG)

.PHONY: build-api
build-api:
	cd server && docker build -t $(API_IMAGE_NAME) . 

build-dev-client: build-api
	cd client && CLIENT_IMAGE_NAME=$(CLIENT_IMAGE_NAME) make build-base

build-production-client: build-api
	cd client && CLIENT_IMAGE_NAME=$(CLIENT_IMAGE_NAME) make build-production-client

push-api: build-api
	docker push $(API_IMAGE_NAME)

push-client: build-production-client
	docker push $(CLIENT_IMAGE_NAME)

push-images:
	$(MAKE) push-api
	$(MAKE) push-client

run-dev:
	docker-compose --file docker-compose-dev.yml up --remove-orphans

bootstrap-db:
	docker-compose --file docker-compose-dev.yml up db bootstrap-db
	docker-compose --file docker-compose-dev.yml down

run-production:
	docker-compose --file docker-compose-production.yml up --remove-orphans


###

# Will need to execute the dump command on droplet directly

# Should write a migration to rename the database and restore
# Staging and Production separately...

dump-db:
	docker exec -i leaguedex_db_1 /bin/bash \
		-c "PGPASSWORD=postgres pg_dumpall \
		--username postgres" > ./dump.sql

restore-db:
	docker-compose --file docker-compose-dev.yml up -d db
	
	sleep 15

	docker exec -i leaguedex_db_1 /bin/bash \
		-c "PGPASSWORD=postgres psql \
		--username postgres" < ./dump.sql

	docker-compose --file docker-compose-dev.yml down

# Will need to drop either the staging or production database
