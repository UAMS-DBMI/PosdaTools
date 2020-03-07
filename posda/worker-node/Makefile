TAG=$(shell git rev-parse --short HEAD)
IMAGE_NAME=tcia/worker-node
.PHONY: push clean

default: build

build: last_built 

last_built: Dockerfile
	docker build . -t ${IMAGE_NAME}:${TAG} -t ${IMAGE_NAME}:latest
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:${TAG}
	docker image push ${IMAGE_NAME}:latest

clean:
	rm -f last_built


test: last_built
	redis-cli lpush work 0
	docker run -it \
		-v ${PWD}/worker-app:/worker \
		-e REDIS_HOST=144.30.104.84 \
		-e PGHOST=144.30.104.84 \
		-e PGPORT=5433 \
		-e PGUSER=postgres \
		-e PGPASSWORD=example \
		-e HOSTNAME=test-node-hostname \
		tcia/worker-node

