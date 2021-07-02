CLIENT_IMAGE_NAME?=unset-tag

build-base:
	docker build --target=base -t $(CLIENT_IMAGE_NAME) .

build-builder:
	docker build --target=builder .

build-production-client:
	docker build --target=production -t $(CLIENT_IMAGE_NAME) .