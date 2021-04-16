#!/usr/bin/env bash

if [ ! -e posda.env ]; then
  echo "Missing posda.env! You must copy posda.env.example to posda.env and edit it first!";
  exit 1;
fi

. posda.env
# TODO: these are for debugging only!

env


perl bin/setup.pl
