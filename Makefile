IMAGE = ogre0403/gemini
VERSION = 0.1.9
TEMP_DIR := $(shell mktemp -d)
PLATFORMS = linux/amd64,linux/arm64


.PHONY: push-release setup-buildx upstream base release

setup-buildx:
	docker buildx create --use --name multiarch || docker buildx use multiarch

push-release: setup-buildx
	docker buildx build \
		--platform $(PLATFORMS) \
		--target release \
		--build-arg VERSION=$(VERSION) \
		--push \
		-t $(IMAGE):$(VERSION) \
		-f Dockerfile .

# Individual stage builds (for testing purposes)
upstream:
	docker build \
		--target upstream \
		--build-arg VERSION=$(VERSION) \
		-t $(IMAGE):$(VERSION)-upstream \
		-f Dockerfile .

base: upstream
	docker build \
		--target base \
		--build-arg VERSION=$(VERSION) \
		-t $(IMAGE):$(VERSION)-base \
		-f Dockerfile .

release: base
	docker build \
		--target release \
		--build-arg VERSION=$(VERSION) \
		-t $(IMAGE):$(VERSION) \
		-f Dockerfile .

