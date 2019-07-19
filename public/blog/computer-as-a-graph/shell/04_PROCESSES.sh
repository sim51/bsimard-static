#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./import.cfg
FILE="$NEO4J_HOME/import/$1/processes.csv"

###############################################################################
### Generate file
###############################################################################
if [[ $# -eq 0  || "$1" == "$LOCAL_SERVER_NAME" ]] ; then
  ps -eo pid,ppid,comm,ruser | awk '{print $1","$2","$3","$4}' > $FILE
else
  ssh $1 ps -eo pid,ppid,comm,ruser | awk '{print $1","$2","$3","$4}' > $FILE
fi
