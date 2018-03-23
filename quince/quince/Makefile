.PHONY: build deploy localdeploy serve

BINLOC=./node_modules/.bin
NG=${BINLOC}/ng

default: build

build: dist

dist: node_modules
	$(NG) build --prod --base-href "/viewer/" --aot=false

deploy:
	scp -r dist/* tcia-utilities:/home/kaleidoscope/viewer/

localdeploy:
	cp -r dist/* /home/www/quince/

serve: node_modules
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --base-href "/viewer"

node_modules: package.json package-lock.json
	npm install
