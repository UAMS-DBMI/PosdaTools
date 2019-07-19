ALLFILES:=$(shell find . -type file)

last_update: Dockerfile $(ALLFILES)
	docker build . -t tcia/lanterna:latest
