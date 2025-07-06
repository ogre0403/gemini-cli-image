# Variables
IMAGE = ogre0403/gemini
VERSION = 0.1.10


.PHONY: base release

base:
	docker build --build-arg VERSION=$(VERSION) -t $(IMAGE):$(VERSION)-base -f Dockerfile.base .

release: base
	docker build --build-arg IMAGE=$(IMAGE) --build-arg VERSION=$(VERSION) -t $(IMAGE):$(VERSION) -f Dockerfile.release .


