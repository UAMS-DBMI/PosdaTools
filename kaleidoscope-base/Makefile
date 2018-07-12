TAG=$(shell git --git-dir=./k-base/.git rev-parse --short HEAD)
IMAGE_NAME=quasarj/k-base
TEST_NAME=k-base_test
.PHONY: push

default: build

build: last_built 

last_built: Dockerfile
	@docker stop ${TEST_NAME} || true
	docker build . -t ${IMAGE_NAME}:${TAG} -t ${IMAGE_NAME}:latest
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:${TAG}
	docker image push ${IMAGE_NAME}:latest
