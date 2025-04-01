#!/bin/bash
. /home/oracle/scripts/setEnv.sh

rman target / log=/home/oracle/rman_full.log <<EORMAN
run {
allocate channel ch1 type DISK format='/backups/DB1/%I-IL0-%Y%M%D-%U';
allocate channel ch2 type DISK format='/backups/DB1/%I-IL0-%Y%M%D-%U';
backup as compressed backupset incremental level 0 database tag='IL0' plus archivelog delete input;
release channel ch1;
release channel ch2;
crosscheck backup;
delete noprompt obsolete;
delete noprompt expired backupset;
}
EORMAN
