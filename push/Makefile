ifndef POSDA_IMG_VERSION
	override POSDA_IMG_VERSION=0
endif
TAG=$(shell git rev-parse --short HEAD)
IMAGE_NAME=tcia/push

last_built: Dockerfile requirements.txt
	docker build .  \
		-t ${IMAGE_NAME}:latest \
		-t ${IMAGE_NAME}:${TAG} \
		-t ${IMAGE_NAME}:${POSDA_IMG_VERSION} 
	date > last_built

push: last_built
	docker image push ${IMAGE_NAME}:latest
	docker image push ${IMAGE_NAME}:${TAG}
	docker image push ${IMAGE_NAME}:${POSDA_IMG_VERSION} 

run: last_built
	docker run -it \
		--env-file prod-database.env \
		--env-file push.env \
		-v ${PWD}:/work \
		-v /nas:/nas \
		${IMAGE_NAME}:latest \
		/work/push.py

test: last_built
	docker run -it \
		--env-file prod-database.env \
		--env-file push.env \
		-v ${PWD}:/work \
		${IMAGE_NAME}:latest \
		bash
