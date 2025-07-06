IMAGE = ogre0403/gemini
VERSION = 0.1.9
TEMP_DIR := $(shell mktemp -d)



.PHONY: base release upstream


upstream:
	echo $(TEMP_DIR)
	git clone https://github.com/google-gemini/gemini-cli.git ${TEMP_DIR}
	cd ${TEMP_DIR} && git checkout v$(VERSION)
	docker run --rm -v ${TEMP_DIR}:/gemini-cli -w /gemini-cli node:20-slim npm install
	docker run --rm \
		-v ${TEMP_DIR}:/gemini-cli \
		-w /gemini-cli \
		node:20-slim \
		bash -c "cd /gemini-cli/packages/cli && \
			npm pack && \
			mv /gemini-cli/packages/cli/*.tgz /gemini-cli/packages/cli/dist/"
	docker run --rm \
		-v ${TEMP_DIR}:/gemini-cli \
		-w /gemini-cli \
		node:20-slim \
		bash -c "cd /gemini-cli/packages/core && \
			npm pack && \
			mv /gemini-cli/packages/core/*.tgz /gemini-cli/packages/core/dist/"
	cd ${TEMP_DIR} && docker build -t $(IMAGE):$(VERSION)-upstream  .
	rm -rf ${TEMP_DIR}



base: 
	docker build --build-arg IMAGE=$(IMAGE) --build-arg VERSION=$(VERSION) -t $(IMAGE):$(VERSION)-base -f Dockerfile.base .

release: base
	docker build --build-arg IMAGE=$(IMAGE) --build-arg VERSION=$(VERSION) -t $(IMAGE):$(VERSION) -f Dockerfile.release .


