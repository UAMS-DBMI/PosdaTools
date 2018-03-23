.PHONY: run stop

default: build

build: last_built

last_built: Dockerfile
	docker build . -t quasarj/posda_nginx:build
	date > last_built

run: build
	docker run --rm -d --name posda_nginx_test -p 80:80 quasarj/posda_nginx:build

stop:
	docker stop posda_nginx_test
