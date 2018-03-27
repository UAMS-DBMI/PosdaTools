IMAGE_NAME=quasarj/k-base:build
TEST_NAME=k-base_test
.PHONY: run stop bash

default: build

build: last_built 

last_built: Dockerfile
	@docker stop ${TEST_NAME} || true
	docker build . -t ${IMAGE_NAME}
	date > last_built

run: build
	docker run --rm -d --name ${TEST_NAME} ${IMAGE_NAME}

run-it: build
	docker run --rm -it ${IMAGE_NAME}

runit: build
	docker run --rm -it --name ${TEST_NAME} ${IMAGE_NAME}

stop:
	docker stop ${TEST_NAME}

bash:
	docker exec -it ${TEST_NAME} sh
