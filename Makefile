default:
	git submodule init
	git submodule update
	make -C docs
	make -C ohif
