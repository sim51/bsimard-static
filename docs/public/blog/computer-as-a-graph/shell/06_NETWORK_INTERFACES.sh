#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./import.cfg
FILE="$NEO4J_HOME/import/$1/network_interfaces.csv"

###############################################################################
### Generate file
###############################################################################
echo 'name,type,ip' > $FILE

if [[ $# -eq 0  || "$1" == "$LOCAL_SERVER_NAME" ]] ; then
  ip -o addr show  | awk '{print $2","$3","$4}' >> $FILE
else
  ssh $1 ip -o addr show  | awk '{print $2","$3","$4}' >> $FILE
fi
