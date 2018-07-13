.PHONY: push

default: build

build: last_built 

last_built: Dockerfile default.conf
	docker build . -t quasarj/posda_nginx:latest
	date > last_built

push:
	docker image push quasarj/posda_nginx:latest
