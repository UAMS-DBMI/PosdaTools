.PHONY: build
build:
	#git submodule init
	#git submodule update
	cp -f default.js Viewers/platform/viewer/public/config/default.js
	docker build -f ./Dockerfile Viewers -t ohif/viewer:builder
