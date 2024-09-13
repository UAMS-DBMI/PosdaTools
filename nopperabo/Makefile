include ../VERSION

.PHONY: build clean

default: build

# Build masker itself
masker/dist/masker-1.0.3-py3-none-any.whl:
	# docker run -it --rm --user $(shell id -u):$(shell id -g) -v ${PWD}/masker:/workdir python:3 /bin/bash -c "cd /workdir; pip install build; python -m build"
	docker run -it --rm -v ${PWD}/masker:/workdir python:3 /bin/bash -c "cd /workdir; pip install build; python -m build"

# Build nopperabo wheel
dist/nopperabo-0.1.0-py3-none-any.whl: masker/dist/masker-1.0.3-py3-none-any.whl
	docker run -t --rm -v ${PWD}:/workdir python:3 /bin/bash -c "cd /workdir; pip install build; python -m build"

# Build actual docker image
build: Dockerfile # masker/dist/masker-1.0.3-py3-none-any.whl dist/nopperabo-0.1.0-py3-none-any.whl
	docker build . -t tcia/nopperabo:${POSDA_IMG_VERSION}

run: 
	docker run \
		-it \
		--rm \
		tcia/nopperabo:${POSDA_IMG_VERSION} --hostname tcia-posda-rh-1.ad.uams.edu --token "e9a63bc2-bfa5-4299-afb3-c844fb2ef38b" --debug true
run-local: 
	docker run \
		-it \
		--rm \
		--network oneposda_default \
		-e LOGURU_LEVEL=INFO \
		-e POSDA_EXTERNAL_HOSTNAME=web:8080 \
		-e POSDA_API_SYSTEM_TOKEN=e9a63bc2-bfa5-4299-afb3-c844fb2ef38b \
		tcia/nopperabo:${POSDA_IMG_VERSION}

test:
	docker run \
		-it \
		--rm \
		tcia/nopperabo:${POSDA_IMG_VERSION} --help
bash:
	docker run \
		-it \
		-v ${PWD}:/scripts \
		--network oneposda_default \
		--entrypoint /bin/bash \
		tcia/nopperabo:${POSDA_IMG_VERSION}

clean:
	rm -rf dist
	rm -rf masker/dist

push: build
	docker image push tcia/nopperabo:${POSDA_IMG_VERSION}
