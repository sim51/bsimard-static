#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./import.cfg
FILE="$NEO4J_HOME/import/$1/groups.csv"

###############################################################################
### Generate file
###############################################################################
echo "name:password:gid:users" > $FILE

if [[ $# -eq 0  || "$1" == "$LOCAL_SERVER_NAME" ]] ; then
  cat /etc/group >> $FILE
else
  ssh $1 cat /etc/group >> $FILE
fi
