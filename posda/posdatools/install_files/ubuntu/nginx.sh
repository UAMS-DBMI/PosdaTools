#!/usr/bin/env bash

sudo mkdir /home/www
sudo chown www-data:posda /home/www
sudo chmod g+rwx /home/www

sudo -u www-data mkdir /home/www/quince
sudo -u www-data mkdir /home/www/kaleidoscope

sudo chgrp posda /home/www/quince /home/www/kaleidoscope
sudo chmod g+rwx /home/www/quince /home/www/kaleidoscope

sudo cp nginx-site.conf /etc/nginx/sites-available/posda.conf
sudo ln -s /etc/nginx/sites-available/posda.conf /etc/nginx/sites-enabled/

sudo rm /etc/nginx/sites-enabled/default

sudo systemctl restart nginx
