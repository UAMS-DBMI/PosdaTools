all: index.js run


run:
	node index.js

index.js: index.ts
	./node_modules/.bin/tsc ./index.ts
