#!/bin/bash

cp /oneposda/install/systemd/* /etc/systemd/system/
cp web/default.conf /etc/nginx/conf.d/

systemctl enable --now redis
systemctl enable --now posda-api
systemctl enable --now posda-ffp
systemctl enable --now nginx
