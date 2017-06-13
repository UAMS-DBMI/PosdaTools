#!/usr/bin/env bash

sudo cp /home/posda/posdatools/systemd/service-files/*.service /etc/systemd/system/
sudo cp /home/posda/quince/server/quince-server.service /etc/systemd/system/
sudo cp /home/posda/kaleidoscope/server/kaleidoscope-server.service /etc/systemd/system/
sudo cp /home/posda/kaleidoscope-base/k-base.service /etc/systemd/system/
sudo systemctl daemon-reload

sudo systemctl enable posda --now
sudo systemctl enable posda-backlog --now
sudo systemctl enable posda-file-process --now
sudo systemctl enable quince-server --now
sudo systemctl enable kaleidoscope-server --now
sudo systemctl enable k-base --now
