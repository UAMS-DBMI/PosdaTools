# Version to tag all images with
export POSDA_IMG_VERSION=1.0.2

default: everything

everything:
	git submodule init
	git submodule update
	make -C docs
	make -C ohif
	make -C web
	make -C posda
	make -C lanterna
	make -C kaleidoscope
	make -C ream
	make -C exodus

test:
	echo "There are no tests yet :("

.PHONY: push
push:
	docker image push tcia/exodus:1.0.2
	docker image push tcia/exodus:latest
	docker image push tcia/ream:1.0.2
	docker image push tcia/ream:latest
	docker image push tcia/lanterna:1.0.2
	docker image push tcia/lanterna:latest
	docker image push tcia/posda:1.0.2
	docker image push tcia/posda:latest
	docker image push tcia/posda_web:1.0.2
	docker image push tcia/posda_web:latest
	docker image push tcia/kaleidoscope:1.0.2
	docker image push tcia/kaleidoscope:latest

