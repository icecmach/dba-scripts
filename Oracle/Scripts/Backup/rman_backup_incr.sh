#!/bin/bash
. /home/oracle/scripts/setEnv.sh

rman target / log=/home/oracle/rman_incr.log <<EORMAN
run {
allocate channel ch1 type DISK format='/backups/DB1/%I-IL1-%Y%M%D-%U';
allocate channel ch2 type DISK format='/backups/DB1/%I-IL1-%Y%M%D-%U';
backup as compressed backupset incremental level 1 database tag='IL1' plus archivelog delete input;
release channel ch1;
release channel ch2;
}
EORMAN
