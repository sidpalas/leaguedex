CLIENT_IMAGE_NAME?=unset-tag

.PHONY: build-base
build-base:
	docker build --target=base -t $(CLIENT_IMAGE_NAME) .

.PHONY: build-builder
build-builder:
	docker build --target=builder .

.PHONY: build-production-client
build-production-client:
	docker build --target=production -t $(CLIENT_IMAGE_NAME) .