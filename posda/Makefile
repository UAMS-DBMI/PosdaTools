.PHONY: run stop bash

default: build

build: last_built 

last_built: Dockerfile
	@docker stop posda2_test || true
	docker build . -t quasarj/posda2:latest
	date > last_built

run: build
	docker run --rm -d --name posda2_test -p 64610:64610 quasarj/posda2:latest

stop:
	docker stop posda2_test

bash:
	docker exec -it posda2_test sh
