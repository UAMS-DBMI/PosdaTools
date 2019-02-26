TAG=$(shell git rev-parse --short HEAD)
IMAGE_NAME=tcia/posda
.PHONY: push clean

default: build

build: last_built 

last_built: Dockerfile
	docker build . -t ${IMAGE_NAME}:${TAG} -t ${IMAGE_NAME}:latest
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:${TAG}
	docker image push ${IMAGE_NAME}:latest

# Special rule to ensure posda.env is in place
posdatools/posda.env: posda.env
	cp posda.env posdatools/

clean:
	rm -f last_built
