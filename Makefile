AGENT=codex
IMAGE = ogre0403/${AGENT}
VERSION = latest
TEMP_DIR := $(shell mktemp -d)
PLATFORMS = linux/amd64,linux/arm64

# Build options
ENABLE_TCPDUMP ?= false
ENABLE_OPENSTACK ?= false
ENABLE_ALL ?= false

# Build args for docker
BUILD_ARGS = --build-arg VERSION=$(VERSION) \
			 --build-arg AGENT=$(AGENT) \
			 --build-arg ENABLE_TCPDUMP=$(ENABLE_TCPDUMP) \
			 --build-arg ENABLE_OPENSTACK=$(ENABLE_OPENSTACK) \
			 --build-arg ENABLE_ALL=$(ENABLE_ALL)


.PHONY: push-release setup-buildx upstream base release

# Show help for enable parameters
.PHONY: help
help:
	@echo "可用的 build 參數："
	@echo "  ENABLE_TCPDUMP=true    啟用 tcpdump/tshark 網路分析工具"
	@echo "  ENABLE_OPENSTACK=true  啟用 OpenStack client 工具 (python-openstackclient)"
	@echo "  ENABLE_ALL=true        啟用所有額外功能 (等同於同時設 true)"
	@echo "預設都為 false，不會安裝上述工具。"


setup-buildx:
	docker buildx create --use --name multiarch || docker buildx use multiarch

push-release: setup-buildx
	docker buildx build \
		--platform $(PLATFORMS) \
		--target release \
		$(BUILD_ARGS) \
		--push \
		-t $(IMAGE):$(VERSION) \
		-f Dockerfile .
	docker buildx rm multiarch || true

# Individual stage builds (for testing purposes)
upstream:
	docker build \
		--target upstream \
		$(BUILD_ARGS) \
		-t $(IMAGE):$(VERSION)-upstream \
		-f Dockerfile .

base: upstream
	docker build \
		--target base \
		$(BUILD_ARGS) \
		-t $(IMAGE):$(VERSION)-base \
		-f Dockerfile .

release: base
	docker build \
		--target release \
		$(BUILD_ARGS) \
		-t $(IMAGE):$(VERSION) \
		-f Dockerfile .

release-all: base
	$(MAKE) release ENABLE_ALL=true


# Clean base and upstream images
.PHONY: clean
clean:
	# Remove intermediate images
	docker rmi -f $(IMAGE):$(VERSION)-base $(IMAGE):$(VERSION)-upstream || true
	# Remove old $(IMAGE) images except current version
	docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | \
		awk -v img="$(IMAGE):$(VERSION)" -v repo="$(IMAGE)" '($$1 ~ "^"repo":") && ($$1 != img) {print $$2}' | \
		xargs -r docker rmi || true
