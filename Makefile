BINLOC=./node_modules/.bin/
NG="${BINLOC}/ng"

build:
	$(NG) build --prod --base-href "/k/"

deploy:
	scp -r dist/* tcia-utilities:/home/kaleidoscope/dist/

localdeploy:
	cp -r dist/* /home/www/kaleidoscope/

serve:
	$(NG) s --proxy-config proxy.conf.json --host 0.0.0.0 --port 4201 --base-href "/k"
