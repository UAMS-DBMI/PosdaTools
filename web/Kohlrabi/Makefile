SRCFILES := $(shell find src -type f)
.PHONY: build deploy localdeploy serve


default: build

build: dist

dist: node_modules $(SRCFILES)
	@echo "Rebuilding because these files changed: $?"
	PUBLIC_URL="/kohlrabi/" npm run build 


serve: node_modules
	npm start

node_modules: package.json package-lock.json
	npm install
