ALLFILES:=$(shell find . -type file)


last_update: Dockerfile $(ALLFILES) dcm4che-5.18.1-bin.zip
	docker build . -t tcia/lanterna:latest

dcm4che-5.18.1-bin.zip: 
	curl "https://gigenet.dl.sourceforge.net/project/dcm4che/dcm4che3/5.18.1/dcm4che-5.18.1-bin.zip" --output $@
