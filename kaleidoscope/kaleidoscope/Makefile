SRCFILES := $(shell find src -type f)
.PHONY: build serve

BINLOC=./node_modules/.bin
NG=${BINLOC}/ng

default: build

build: dist

dist: node_modules $(SRCFILES)
	@echo "Rebuilding because these files changed: $?"
	$(NG) build --prod --base-href "/k/"

serve: node_modules
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --port 4201 --base-href "/k"

node_modules: package.json package-lock.json
	npm install
