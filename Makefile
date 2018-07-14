.PHONY: build serve /html

BINLOC=./node_modules/.bin
NG=${BINLOC}/ng

default: build

build: /html

/html: node_modules
	$(NG) build --prod --base-href "/k/"
	mv dist/* $@

serve: node_modules
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --port 4201 --base-href "/k"

node_modules: package.json
	npm install
