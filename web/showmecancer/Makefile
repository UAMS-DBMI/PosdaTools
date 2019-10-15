SRCFILES := $(shell find src -type f)
.PHONY: build deploy localdeploy serve

BINLOC=./node_modules/.bin
NG=${BINLOC}/ng

default: build

build: dist

dist: node_modules $(SRCFILES)
	@echo "Rebuilding because these files changed: $?"
	$(NG) build --prod --base-href "/viewer/"

serve: node_modules
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --base-href "/viewer"

node_modules: package.json package-lock.json
	npm install
