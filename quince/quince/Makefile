.PHONY: build deploy localdeploy serve

BINLOC=./node_modules/.bin
NG=${BINLOC}/ng

default: build

build: /html

/html: node_modules
	$(NG) build --prod --base-href "/viewer/" --aot=false
	cp -r dist/* /html/

serve: node_modules
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --base-href "/viewer"

node_modules: package.json package-lock.json
	npm install
