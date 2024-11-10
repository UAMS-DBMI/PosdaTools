#!/bin/bash

if [ -z "$CONFIG_DIR" ]; then
        echo "Missing install configuration, load CONFIG first!";
        exit 1;
fi


yum install -y \
	bzip2-devel \
	xz-devel \
	zlib-devel \
	libpng \
	libjpeg \
	openjpeg2 \
	libtiff-devel \
	libpng-devel \
	libjpeg-turbo-devel


BUILD_DIR=/tmp/build
LANTERNA_DIR=$ONEPOSDA_LOCATION/lanterna

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

tar xf $LANTERNA_DIR/ImageMagick-7.0.8-49.tar.gz
cp $LANTERNA_DIR/dcm_add_force_unsigned.patch ./

cd ImageMagick-7.0.8-49
patch -p1 -i ../dcm_add_force_unsigned.patch
./configure --prefix=/opt/im
make -j $(nproc)
make install


# dcm4chee

dcm4che-5.22.1-bin.zip:
# Attempt to download dcm4che
curl "https://master.dl.sourceforge.net/project/dcm4che/dcm4che3/5.22.1/dcm4che-5.22.1-bin.zip?viasf=1" --output /tmp/dcm4che.zip
unzip /tmp/dcm4che.zip -d /opt
rm -f /tmp/dcm4che.zip

