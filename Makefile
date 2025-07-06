


base:
	docker build -t ogre0403/gemini:0.1.10-base -f Dockerfile.base .


release: base
	docker build -t ogre0403/gemini:0.1.10 -f Dockerfile.release .
