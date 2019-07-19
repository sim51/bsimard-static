#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./import.cfg
FILE="$NEO4J_HOME/import/$1/users.csv"

###############################################################################
### Generate file
###############################################################################
echo "username:password:uid:gid:info:home:shell" > $FILE

if [[ $# -eq 0  || "$1" == "$LOCAL_SERVER_NAME" ]] ; then
  cat /etc/passwd >> $FILE
else
  ssh $1 cat /etc/passwd >> $FILE
fi