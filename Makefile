build-api:
	cd server && docker build -t leaguedex-api . 

build-dev: build-api
	cd client && make build-base

build-production: build-api
	cd client && make build-production

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
