#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./import.cfg
FILE="$NEO4J_HOME/import/$1/hardware.json"

###############################################################################
### Generate file
###############################################################################
if [[ $# -eq 0  || "$1" == "$LOCAL_SERVER_NAME" ]] ; then
  sudo lshw -json > $FILE
else
  ssh $1 sudo lshw -json > $FILE
fi

# Correct bad json format ...
sed -i "s/}\s*{/}},{/g" $FILE
