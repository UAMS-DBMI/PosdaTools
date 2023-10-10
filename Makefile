# Version to tag all images with
export POSDA_IMG_VERSION=1.0

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
