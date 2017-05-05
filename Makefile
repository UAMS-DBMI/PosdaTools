all: index.js clean run open

clean:
	rm -f *.png

run:
	node index.js

index.js: index.ts
	./node_modules/.bin/tsc ./index.ts
open:
	chromium *.png
