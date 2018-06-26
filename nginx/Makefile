.PHONY: run stop bash

default: build

build: last_built 

last_built: Dockerfile default.conf quince/dist kaleidoscope/dist
	@docker stop posda_nginx_test || true
	docker build . -t quasarj/posda_nginx:latest
	date > last_built

run: build
	docker run --rm -d --name posda_nginx_test -p 80:80 quasarj/posda_nginx:latest

stop:
	docker stop posda_nginx_test

bash:
	docker exec -it posda_nginx_test sh

quince/dist:
	make -C quince dist

kaleidoscope/dist:
	make -C kaleidoscope dist
