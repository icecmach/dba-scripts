#!/bin/ksh
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    rman_consolidated_report.ksh
#%
#% DESCRIPTION
#%    Sends a report of the RMAN backups for all instances
#%    running in the server
#%
#================================================================
#- IMPLEMENTATION
#-    version         1.0
#-    author          Andre
#-
#================================================================
#  HISTORY
#     2023/09/12 : Script creation
#
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#================================================================
# END_OF_HEADER
#================================================================

#================================================================
# Set Environment Variables
#================================================================
export ORACLE_HOME=`grep app /etc/oratab -m 1 | cut -d':' -f2`
export ORACLE_BASE=`echo ${ORACLE_HOME} | sed -e 's:/product/.*::g'`
export PATH=$ORACLE_HOME/bin:$PATH
export ORAENV_ASK=NO
HOSTNAME=`uname -n`
SENDER=${HOSTNAME}@orcl.com
DATE=`date '+%b%d'`
ADMINDIR=${ORACLE_BASE}/admin
LOGDIR=${ADMINDIR}/*/log/rman
LOGFILE=backup_report_*_${DATE}.log
TMPLOGFILE=/tmp/backup_report_consolidated.log

. ${HOME}/.dbalist

#================================================================
# MAIN Section
#================================================================
for LOG in `find ${LOGDIR} -name ${LOGFILE} -print`
do
   cat ${LOG} >> ${TMPLOGFILE}
   echo "" >> ${TMPLOGFILE}
done

cat ${TMPLOGFILE} | mailx -r ${SENDER} -s "RMAN Backup Report ${HOSTNAME}" ${DBA}
rm ${TMPLOGFILE}
