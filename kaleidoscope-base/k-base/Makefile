.PHONY: default build open run_forever clean

default: build

clean:
	rm -f *.png

run: node_modules
	node index.js

build: index.js finish.js image.js

index.js image.js finish.js: index.ts image.ts finish.ts node_modules
	./node_modules/.bin/tsc

open:
	chromium *.png

run_forever: node_modules
	while true; do node index.js; done

node_modules: package.json
	npm install
