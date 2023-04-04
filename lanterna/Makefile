ALLFILES:=$(shell find . -type file)


last_update: Dockerfile $(ALLFILES) dcm4che-5.22.1-bin.zip
	docker build . -t tcia/lanterna:latest

dcm4che-5.22.1-bin.zip: 
	curl "https://master.dl.sourceforge.net/project/dcm4che/dcm4che3/5.22.1/dcm4che-5.22.1-bin.zip?viasf=1" --output $@
