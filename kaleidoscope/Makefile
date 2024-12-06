include ../VERSION

TAG=$(shell git rev-parse --short HEAD)
IMAGE_NAME=tcia/kaleidoscope
.PHONY: push clean

default: build

build: last_built 

last_built: Dockerfile
	docker build .  \
		-t ${IMAGE_NAME}:latest \
		-t ${IMAGE_NAME}:${TAG} \
		-t ${IMAGE_NAME}:${POSDA_IMG_VERSION} 
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:latest
	docker image push ${IMAGE_NAME}:${TAG}
	docker image push ${IMAGE_NAME}:${POSDA_IMG_VERSION} 

clean:
	rm -f last_built
