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
    clear_cache;
    clear_databases;

}
clear_databases() {
    perl bin/reset.pl
    echo "Done."
}

clear_cache() {
    echo "Deleting all files in cache...";
    find $POSDA_CACHE_ROOT -type f -delete
    echo "Done."
}


warning;
