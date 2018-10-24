#!/usr/bin/env bash

if [ ! -e posda.env ]; then
  echo "Missing posda.env! You must copy posda.env.example to posda.env and edit it first!";
  exit 1;
fi

. posda.env


warning() {

    echo "This script will reset your Posda instance.";
    echo "THIS WILL DELETE EVERYTHING!!!";
    echo "type YES and press enter to continue";

    read YES;

    if [ "$YES" == "YES" ]; then
        echo "Okay, here we go...";
        main;
    fi

}

main() {
    stop_services;
    clear_cache;
    clear_databases;
    start_services;

}
clear_databases() {
    perl bin/reset.pl
    echo "Done."
}

clear_cache() {
    echo "Deleting all files in cache...";
    find $POSDA_CACHE_ROOT -type f -delete
    rm /home/posda/FilesAlreadySeen
    echo "Done."
}

stop_services() {
    sudo systemctl stop posda-backlog
    sudo systemctl stop posda-file-process
    sudo systemctl stop posda
}

start_services() {
    sudo systemctl start posda
    sudo systemctl start posda-file-process
    sudo systemctl start posda-backlog
}


warning;
