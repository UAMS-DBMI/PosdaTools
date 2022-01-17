TAG=$(shell git rev-parse --short HEAD)
IMAGE_NAME=tcia/posda_web
.PHONY: push clean

default: build

build: last_built 

last_built: Dockerfile default.conf
	cd ../docs && mkdocs build
	docker build . -t ${IMAGE_NAME}:${TAG}k -t ${IMAGE_NAME}:kubes
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:${TAG}k
	docker image push ${IMAGE_NAME}:kubes

clean:
	rm -f last_built
