#!/bin/bash

set -e

export ORACLE_SID=${1}
export ORACLE_BASE=/u01/app/oracle

. oraenv

export PATH=${ORACLE_HOME}/bin:${PATH}
export NLS_LANG=AMERICAN_AMERICA.WE8MSWIN1252
export NLS_DATE_FORMAT="YYYY-Mon-DD HH24:MI:SS"
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib

source /home/oracle/DBA/scripts/.dbalist

sqlplus "/ as sysdba" <<EOF
@/home/oracle/DBA/scripts/cdc_healthcheck.sql
EOF

mv /home/oracle/DBA/scripts/cdc-health.html /home/oracle/DBA/scripts/cdc-health-${ORACLE_SID}.html

cat <<EOF | /usr/sbin/sendmail -t
To: ${DbaMail}
Subject: CDC Configuration Check for ${ORACLE_SID}
MIME-Version: 1.0
Content-Type: text/html; charset="us-ascii"

$(cat /home/oracle/DBA/scripts/cdc-health-${ORACLE_SID}.html)
EOF