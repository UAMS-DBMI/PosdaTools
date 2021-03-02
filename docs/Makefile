.PHONY: clean serve
SOURCES := $(shell find src -type f)

default: ../web/www/docs

serve: mkdocs.yml $(SOURCES)
	docker run --rm -v `pwd`:/app -w /app -p 8182:8182 minidocks/mkdocs:1.0 serve -a 0.0.0.0:8182


build: mkdocs.yml $(SOURCES)
	docker run --rm -v `pwd`:/app -w /app minidocks/mkdocs:1.0 build

../web/www/docs: build
	cp -r build/* ../web/www/docs/


clean:
	rm -rf build
