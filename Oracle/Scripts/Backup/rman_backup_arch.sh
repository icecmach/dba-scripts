#!/bin/bash
. /home/oracle/scripts/setEnv.sh

rman target / log=/home/oracle/rman_arch.log <<EORMAN
run {
allocate channel ch1 type DISK format='/backups/DB1/%I-ARC-%Y%M%D-%U';
backup archivelog all tag='ARC' delete input;
release channel ch1;
}
EORMAN
