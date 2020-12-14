#! /bin/sh

# runs bash in the image
# provide the image id as a parameter of the script

docker run --init -it --user vscode $1 bash