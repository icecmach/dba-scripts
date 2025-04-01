#!/bin/ksh
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    rman_report.ksh
#%
#% DESCRIPTION
#%    Sends a report of the latest RMAN backups
#%
#================================================================
#- IMPLEMENTATION
#-    version         1.1
#-    author          Andre
#-
#================================================================
#  HISTORY
#     2023/06/14 : Script creation
#     2023/09/12 : Keep log file and don't send email
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
export ORACLE_SID=$1
export ORACLE_HOME=`grep ${ORACLE_SID} /etc/oratab | cut -d':' -f2`
export ORACLE_BASE=`echo ${ORACLE_HOME} | sed -e 's:/product/.*::g'`
export PATH=$ORACLE_HOME/bin:$PATH
export ORAENV_ASK=NO
HOSTNAME=`uname -n`
SENDER=${HOSTNAME}.${ORACLE_SID}@orcl.com
DATE=`date '+%b%d'`
ADMINDIR=${ORACLE_BASE}/admin
LOGDIR=${ADMINDIR}/${ORACLE_SID}/log/rman
LOGFILE=${LOGDIR}/backup_report_${ORACLE_SID}_${DATE}.log

. /usr/local/bin/oraenv -s
#. ${HOME}/.dbalist

#================================================================
# MAIN Section
#================================================================
RESULT=`sqlplus -s "/ as sysdba" << EOF
    set linesize 180
    Col session_key           for 999999
    Col start_time            for a22
    Col end_time              for a22
    Col status                for a10
    Col time_taken_display    for a10
    Col output_bytes_display  for a20
    Col input_type            for a10
    Col output_device_type    for a10

    spool ${LOGFILE}

    SELECT instance_name
    FROM V\\$INSTANCE;

    SELECT session_key,
        TO_CHAR(jd.start_time, 'dd/MON/yyyy hh24:mi:ss') start_time,
        TO_CHAR(jd.end_time, 'dd/MON/yyyy hh24:mi:ss') end_time,
        jd.status,
        jd.time_taken_display,
        jd.output_bytes_display,
        jd.input_type,
        jd.output_device_type
    FROM V\\$RMAN_BACKUP_JOB_DETAILS jd
    WHERE start_time > TRUNC(SYSDATE,'DAY')
    ORDER BY SESSION_KEY DESC;

    spool off
EOF`

echo "#================================================================" >> ${LOGFILE}
echo "# Latest RMAN log files" >> ${LOGFILE}
echo "#================================================================" >> ${LOGFILE}
ls -t /u01/app/oracle/admin/${ORACLE_SID}/log/rman/rman_*.log | grep -v '_tmp' | head -n4 >> ${LOGFILE}

#cat ${LOGFILE} | mailx -r ${SENDER} -s "RMAN Backup Report ${ORACLE_SID}" ${DBA}

#================================================================
# Delete old log file(s)
#================================================================
for LOG in `find ${LOGDIR} -name "backup_report_${ORACLE_SID}_*.log" -mtime +7 -print`
do
   rm ${LOG}
done
