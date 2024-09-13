# Version to tag all images with
include ./VERSION

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
	make -C nopperabo

test:
	echo "There are no tests yet :("

.PHONY: push
push:
	docker image push tcia/exodus:${POSDA_IMG_VERSION}
	docker image push tcia/exodus:latest
	docker image push tcia/ream:${POSDA_IMG_VERSION}
	docker image push tcia/ream:latest
	docker image push tcia/lanterna:${POSDA_IMG_VERSION}
	docker image push tcia/lanterna:latest
	docker image push tcia/posda:${POSDA_IMG_VERSION}
	docker image push tcia/posda:latest
	docker image push tcia/posda_web:${POSDA_IMG_VERSION}
	docker image push tcia/posda_web:latest
	docker image push tcia/kaleidoscope:${POSDA_IMG_VERSION}
	docker image push tcia/kaleidoscope:latest
	docker image push tcia/nopperabo:${POSDA_IMG_VERSION}
	docker image push tcia/nopperabo:latest
