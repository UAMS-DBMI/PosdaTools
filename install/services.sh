#!/bin/bash

./posda-setup.sh

cp /oneposda/install/systemd/* /etc/systemd/system/
cp web/default.conf /etc/nginx/conf.d/
cp web/nginx.conf /etc/nginx/

systemctl enable --now redis
systemctl enable --now posda-api
systemctl enable --now posda-ffp
systemctl enable --now nginx
systemctl enable --now posda
systemctl enable --now posda-worker-low
systemctl enable --now posda-worker-high

