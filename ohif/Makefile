.PHONY: build
build:
	git submodule init
	git submodule update
	docker build -f ./Dockerfile Viewers -t ohif/viewer:builder
