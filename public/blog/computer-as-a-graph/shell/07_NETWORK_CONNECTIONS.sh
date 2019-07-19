#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./import.cfg
FILE="$NEO4J_HOME/import/$1/network_connections.csv"

###############################################################################
### Generate file
###############################################################################
echo 'protocole,local,remote,state,user,pid' > $FILE

if [[ $# -eq 0  || "$1" == "$LOCAL_SERVER_NAME" ]] ; then
  sudo netstat -alpuetn | tail -n +3 | awk '{print $1","$4","$5","$6","$7","$9}' >> $FILE
else
  ssh $1 sudo netstat -alpuetn | tail -n +3 | awk '{print $1","$4","$5","$6","$7","$9}' >> $FILE
fi
