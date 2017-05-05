all: build clean run open

clean:
	rm -f *.png

run:
	node index.js

build:
	./node_modules/.bin/tsc

open:
	chromium *.png
