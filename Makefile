# test comment

default:
	git submodule init
	git submodule update
	make -C docs
	make -C ohif
	make -C web
	make -C posda
	make -C lanterna
	make -C kaleidoscope
