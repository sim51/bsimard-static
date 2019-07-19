#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./`basename $0 .sh`.cfg
# See getent command

###############################################################################
# CONSTANTS
###############################################################################
DATE=`date +%Y%m%d-%H%M`
WORK=$PWD
TMP=$(mktemp -d)

###############################################################################
# MAIN
###############################################################################

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Running import script : $DATE"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

if [[ "$1" == "reset" ]] ; then
  echo
  echo "*********************************************************************************************************"
  echo "Shutdown Neo4j"
  echo "*********************************************************************************************************"
  bash $NEO4J_HOME/bin/neo4j stop

  echo
  echo "*********************************************************************************************************"
  echo "Delete Neo4j graph.db folder"
  echo "*********************************************************************************************************"
  rm -rf $NEO4J_HOME/data/databases/graph.db

  echo
  echo "*********************************************************************************************************"
  echo "Startup Neo4j"
  echo "*********************************************************************************************************"
  bash $NEO4J_HOME/bin/neo4j start

  # Waiting until Neo4j is not available
  until $(curl --output /dev/null --silent --head --fail http://localhost:7474); do
      printf '.'
      sleep 1
  done

fi

#SERVERS=$(nmap -sn 10.0.0.1/24 | grep 'Nmap scan report for' | sed 's/^Nmap scan report for \(.*\) (\(.*\))/\1/'))
SERVERS=( "pythagore.logisima" "osmc.logisima" "dijsktra.logisima" "ipfire.logisima" "euler.logisima")

echo
echo "*********************************************************************************************************"
echo "Discover network"
echo "*********************************************************************************************************"

for fqdn in ${SERVERS[@]};
do
  echo
  echo "  - Found $fqdn"
  echo "  -----------------------"
  mkdir -p $NEO4J_HOME/import/$fqdn

  for file in $GENERATORS/*.sh
  do
    echo "    . Processing $file"
    bash $file $fqdn
  done
done

echo
echo "*********************************************************************************************************"
echo "Executing cypher scripts"
echo "*********************************************************************************************************"
for fqdn in ${SERVERS[@]};
do
  echo
  echo "  - Import $fqdn"
  echo "  -----------------------"

  TMPDIR=$(mktemp -d)
  cp $CYPHER_PATH/*.cyp $TMPDIR
  for file in $TMPDIR/*.cyp
  do
    sed -i "s/@@FQDN@@/$fqdn/g" $file
  done

  for file in $TMPDIR/*.cyp
  do
    echo "    . Processing $file"
    bash $NEO4J_HOME/bin/cypher-shell -u $NEO4J_LOGIN -p $NEO4J_PASSWORD --fail-fast --format verbose < $file
  done

done
