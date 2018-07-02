.PHONY: build deploy localdeploy serve

BINLOC=./node_modules/.bin
NG=${BINLOC}/ng

default: build

build: dist

dist: node_modules
	$(NG) build --prod --base-href "/k/"

deploy:
	scp -r dist/* tcia-utilities:/home/kaleidoscope/dist/

localdeploy:
	cp -r dist/* /home/www/kaleidoscope/

serve: node_modules
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --port 4201 --base-href "/k"

node_modules: package.json package-lock.json
	npm install
