#!/bin/bash

if [ -z "$CONFIG_DIR" ]; then
        echo "Missing install configuration, load CONFIG first!";
        exit 1;
fi

$INSTALL_DIR/install-scripts/posda-setup.sh
$INSTALL_DIR/install-scripts/k-deps.sh

cp $INSTALL_DIR/systemd/* /etc/systemd/system/
cp $INSTALL_DIR/web/default.conf /etc/nginx/conf.d/
cp $INSTALL_DIR/web/nginx.conf /etc/nginx/

systemctl enable --now redis
systemctl enable --now posda-api
systemctl enable --now posda-ffp
systemctl enable --now nginx
systemctl enable --now posda
systemctl enable --now posda-worker-low
systemctl enable --now posda-worker-high
systemctl enable --now kaleidoscope
systemctl enable --now magicka

