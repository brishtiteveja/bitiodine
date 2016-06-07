#!/bin/sh

# Stop bitcoind
bcli stop && sleep 10

# Create a lock file used by BitIodine server to abort restarts
touch /tmp/bitiodine_update_in_progress

TIMESTAMP=`date --rfc-3339=seconds`
BITIODINE_HOME=/scratch2/azehady/projects
cd $BITIODINE_HOME/bitiodine/
echo "$TIMESTAMP Updating..." >> bitiodine.log

cd $BITIODINE_HOME/bitiodine/deploy/blockparser/
./parser sql && cd ../clusterizer && ./clusterizer.py --generate-clusters && ./clusterizer.py --csv && cd ../server

# Send QUIT command to existing instances
echo QUIT | nc -i 3 -q 5 127.0.0.1 8888
# Restart BitIodine
screen -S bitiodine -d -m ./bitiodine_server

TIMESTAMP=`date --rfc-3339=seconds`
echo "$TIMESTAMP Updated." >> ../../bitiodine.log

# Restart bitcoind
bqtd -datadir=/scratch2/azehady/data/bit

# Remove lock file
rm -f /tmp/bitiodine_update_in_progress
