#!/bin/bash

###############################################################################
### Loading the environment file with the extention ".cfg" intead of ".sh"
###############################################################################
source  ./import.cfg
FILE="$NEO4J_HOME/import/$1/packages.csv"

###############################################################################
### Generate file
###############################################################################
echo -e "section\tpackage\tversion\tarchitecture\thomepage\tdependencies" > $FILE
if [[ $# -eq 0  || "$1" == "$LOCAL_SERVER_NAME" ]] ; then
  dpkg-query -Wf '${Section}\t${Package}\t${Version}\t${Architecture}\t${Homepage}\t${Depends}\n' >> $FILE
else
  ssh $1 dpkg-query -Wf '\${Section}\\t\${Package}\\t\${Version}\\t\${Architecture}\\t\${Homepage}\\t\${Depends}\\n' >> $FILE
fi
