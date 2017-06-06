BINLOC=./node_modules/.bin/
NG="${BINLOC}/ng"

build:
	$(NG) build --prod --base-href "/viewer/"

deploy:
	scp -r dist/* tcia-utilities:/home/kaleidoscope/viewer/

serve:
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --base-href "/viewer"
