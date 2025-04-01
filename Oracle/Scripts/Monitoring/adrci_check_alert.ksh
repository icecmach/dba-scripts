#!/bin/ksh
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    adrci_check_alert.ksh
#%
#% DESCRIPTION
#%    Checks for "ORA-" messages in the alert log file
#%
#================================================================
#- IMPLEMENTATION
#-    version         1.0
#-    author          Andre
#-
#================================================================
#  HISTORY
#     2023/06/27 : Script creation
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
# Check parameters
#================================================================
if (( ${#} != 1 ))
then
   echo "Usage: ksh adrci_check_alert.ksh { ORACLE_SID }"
   exit
fi

#================================================================
# Set Environment Variables
#================================================================
export ORACLE_SID=$1
export ORACLE_HOME=`grep ${ORACLE_SID} /etc/oratab | cut -d':' -f2`
export ORACLE_BASE=/u01/app/oracle/product
export PATH=$ORACLE_HOME/bin:$PATH
HOSTNAME=`uname -n`
SENDER=${HOSTNAME}.${ORACLE_SID}@orcl.com
ADMINDIR=`echo $ORACLE_HOME | sed -e 's:/product/.*::g'`/admin
LOGDIR=${ADMINDIR}/${ORACLE_SID}/log/adrci_check_alert
LOGFILE=${LOGDIR}/adrci_check_alert_${ORACLE_SID}.log
ADRSCRIPT=${LOGDIR}/adrci_${ORACLE_SID}.adrci

. ${HOME}/.dbalist

#================================================================
# MAIN Section
#================================================================
if [ ! -d ${LOGDIR} ]
then
    mkdir -p ${LOGDIR}
fi

#-----------------------------------------------------------#
# Get diagnostic variables
#-----------------------------------------------------------#
RESULT=`sqlplus -s "/ as sysdba" << EOF
    set echo off
    set feedback off
    set heading  off

    SELECT substr(replace(homepath.value,adrbase.value), 2) ADR_HOME
    FROM v\\$diag_info homepath, v\\$diag_info adrbase
    WHERE homepath.name = 'ADR Home'
    AND adrbase.name  = 'ADR Base';
EOF`

ADRHOME=${RESULT//[$'\t\r\n']}

#-----------------------------------------------------------#
# Execute ADRCI script
#-----------------------------------------------------------#
echo "set homepath ${ADRHOME}" > ${ADRSCRIPT}
echo "spool ${LOGFILE}"        >> ${ADRSCRIPT}
echo "show alert -p \"message_text like '%ORA-%' and originating_timestamp between systimestamp - 5/(24*60) and systimestamp\" -term" >> ${ADRSCRIPT}
echo "purge -age 43200"        >> ${ADRSCRIPT}
echo "spool off"               >> ${ADRSCRIPT}

adrci script=${ADRSCRIPT}

#-----------------------------------------------------------#
# Check for ORA-* errors
#-----------------------------------------------------------#
#Ignore specific Oracle errors
#00060 deadlock detected while waiting for resource
#01555 snapshot too old
IGNORE_MSG="00060"
IGNORE_MSG_CUSTOM="01555.*6kz2vnrj5gt91"

if ! grep -q -E "$IGNORE_MSG_CUSTOM" "$LOGFILE"
then
    if grep "^ORA-" "$LOGFILE" | grep -v -E "$IGNORE_MSG"
    then
        cat ${LOGFILE} | mailx -r ${SENDER} -s "WARNING: DB Server ${HOSTNAME} ${ORACLE_SID}: Check alert log" ${DBA}
    fi
fi

#-----------------------------------------------------------#
# ADRCI rotates .xml log files but text-based .log
# have to be rotated manually (Doc ID 751082.1)
#-----------------------------------------------------------#
# The keep variable controls how many old alert logs should be kept
keep=30
cd ${ORACLE_BASE}/${ADRHOME}/trace

#-----------------------------------------------------------#
# Switch alert_log / Delete old alert log
#-----------------------------------------------------------#
if [ `date +%d` = 28 ]
then
    if [ ! -f "`date +%y%m`.alert_${ORACLE_SID}.log.gz" ]
    then
        cp alert_${ORACLE_SID}.log `date +%y%m`.alert_${ORACLE_SID}.log
        gzip `date +%y%m`.alert_${ORACLE_SID}.log
        > alert_${ORACLE_SID}.log

        for FILE in `find ${ORACLE_BASE}/${ADRHOME}/trace -name "*.log.gz" -mtime +${keep} -print`
        do
            rm ${FILE}
        done
    fi
fi
