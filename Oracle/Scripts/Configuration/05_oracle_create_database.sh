echo "******************************************************************************"
echo "Create a listener.ora file if it doesn't already exist." `date`
echo "******************************************************************************"
if [ ! -f ${ORACLE_HOME}/network/admin/listener.ora ]; then
    cat > $ORACLE_HOME/network/admin/listener.ora <<EOF
LISTENER =
(DESCRIPTION_LIST =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  )
)
USE_SID_AS_SERVICE_listener=on
INBOUND_CONNECT_TIMEOUT_LISTENER=400
EOF

    cat > $ORACLE_HOME/network/admin/tnsnames.ora <<EOF
LISTENER = (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
${ORACLE_SID}=
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = ${ORACLE_SID})
  )
)
${PDB_NAME}=
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = ${PDB_NAME})
  )
)
EOF

    cat > ${ORACLE_HOME}/network/admin/sqlnet.ora <<EOF
SQLNET.INBOUND_CONNECT_TIMEOUT=400
EOF
fi

echo "******************************************************************************"
echo "Check if database already exists." `date`
echo "******************************************************************************"
if [ ! -d ${DATA_DIR}/${ORACLE_SID^^} ]; then

    export SYS_PASSWORD="SysPassword1"
    export PDB_PASSWORD="PdbPassword1"

    echo "******************************************************************************"
    echo "Creating database ${ORACLE_SID}." `date`
    echo "******************************************************************************"
    lsnrctl start

    dbca -silent -createDatabase                                     \
    -templateName General_Purpose.dbc                                \
    -gdbname ${ORACLE_SID} -sid ${ORACLE_SID} -responseFile NO_VALUE \
    -characterSet AL32UTF8                                           \
    -sysPassword ${SYS_PASSWORD}                                     \
    -systemPassword ${SYS_PASSWORD}                                  \
    -createAsContainerDatabase true                                  \
    -numberOfPDBs 1                                                  \
    -pdbName ${PDB_NAME}                                             \
    -pdbAdminPassword ${PDB_PASSWORD}                                \
    -databaseType MULTIPURPOSE                                       \
    -memoryMgmtType auto_sga                                         \
    -totalMemory 1536                                                \
    -storageType FS                                                  \
    -datafileDestination "${DATA_DIR}"                               \
    -redoLogFileSize 50                                              \
    -emConfiguration NONE                                            \
    -ignorePreReqs

    echo "******************************************************************************"
    echo "Set the PDB to auto-start." `date`
    echo "******************************************************************************"
    sqlplus / as sysdba <<EOF
alter system set db_create_file_dest='${DATA_DIR}';
alter pluggable database ${PDB_NAME} save state;
alter system set local_listener='LISTENER';
exit;
EOF

    echo "******************************************************************************"
    echo "Flip the auto-start flag." `date`
    echo "******************************************************************************"
    cp /etc/oratab /tmp
    sed -i -e "s|${ORACLE_SID}:${ORACLE_HOME}:N|${ORACLE_SID}:${ORACLE_HOME}:Y|g" /tmp/oratab
    cp -f /tmp/oratab /etc/oratab
else
    echo "******************************************************************************"
    echo "Database ${ORACLE_SID} already exists, exiting." `date`
    echo "******************************************************************************"
fi
