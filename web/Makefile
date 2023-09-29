TAG=$(shell git rev-parse --short HEAD)
IMAGE_NAME=tcia/posda_web
.PHONY: push clean

default: build

build: last_built 

last_built: Dockerfile default.conf
	docker build . -t ${IMAGE_NAME}:${TAG} -t ${IMAGE_NAME}:latest
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:${TAG}
	docker image push ${IMAGE_NAME}:latest

clean:
	rm -f last_built


dev: Dockerfile
	docker run -it \
		-p 4200:4200 \
		-v $(PWD):/work \
		-w /work \
		node:16-alpine sh
