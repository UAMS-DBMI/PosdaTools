#!/bin/bash

echo "This script must be run on a machine with docker and the"
echo "tcia/posda_web:latest image available."
echo

echo "First, cleaning up the existing dir..."
rm -rf www

echo "Creating a temp container of the image..."
docker create --name tempweb tcia/posda_web:latest

echo "Copying the files..."
docker cp tempweb:/www . 

echo "Removing the temporary container..."
docker rm tempweb

echo "Done"
