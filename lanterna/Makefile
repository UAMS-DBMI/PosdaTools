ifndef POSDA_IMG_VERSION
	override POSDA_IMG_VERSION=0
endif
TAG=$(shell git rev-parse --short HEAD)
IMAGE_NAME=tcia/lanterna
ALLFILES:=$(shell find . -type file)


last_built: Dockerfile $(ALLFILES) dcm4che-5.22.1-bin.zip
	docker build .  \
		-t ${IMAGE_NAME}:latest \
		-t ${IMAGE_NAME}:${TAG} \
		-t ${IMAGE_NAME}:${POSDA_IMG_VERSION} 
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:latest
	docker image push ${IMAGE_NAME}:${TAG}
	docker image push ${IMAGE_NAME}:${POSDA_IMG_VERSION} 

dcm4che-5.22.1-bin.zip: 
	curl "https://master.dl.sourceforge.net/project/dcm4che/dcm4che3/5.22.1/dcm4che-5.22.1-bin.zip?viasf=1" --output $@
