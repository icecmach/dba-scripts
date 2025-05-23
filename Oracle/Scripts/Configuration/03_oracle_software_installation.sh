echo "******************************************************************************"
echo "Unzip software." `date`
echo "******************************************************************************"

cd $ORACLE_HOME
echo "Unzipping /u01/software/${DB_SOFTWARE} into ${ORACLE_HOME}"
unzip -oq /u01/software/$DB_SOFTWARE
unzip -oq /u01/software/$OPATCH_FILE

cd $SOFTWARE_DIR
echo "Unzipping /u01/software/${PATCH_FILE} into ${SOFTWARE_DIR}"
unzip -oq /u01/software/$PATCH_FILE

echo "******************************************************************************"
echo "Do software-only installation." `date`
echo "******************************************************************************"
# Fake Oracle Linux 8.
# Should not be necessary, but the installation fails without it on 19.21 DB RU + OJVM combo.
export CV_ASSUME_DISTID=OL8

$ORACLE_HOME/runInstaller -ignorePrereq -waitforcompletion -silent \
    -applyRU $PATCH_PATH1                                          \
    -responseFile $ORACLE_HOME/install/response/db_install.rsp     \
    oracle.install.option=INSTALL_DB_SWONLY                        \
    ORACLE_HOSTNAME=$ORACLE_HOSTNAME                               \
    UNIX_GROUP_NAME=oinstall                                       \
    INVENTORY_LOCATION=$ORA_INVENTORY                              \
    SELECTED_LANGUAGES=en                                          \
    ORACLE_HOME=$ORACLE_HOME                                       \
    ORACLE_BASE=$ORACLE_BASE                                       \
    oracle.install.db.InstallEdition=EE                            \
    oracle.install.db.OSDBA_GROUP=dba                              \
    oracle.install.db.OSBACKUPDBA_GROUP=dba                        \
    oracle.install.db.OSDGDBA_GROUP=dba                            \
    oracle.install.db.OSKMDBA_GROUP=dba                            \
    oracle.install.db.OSRACDBA_GROUP=dba                           \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                     \
    DECLINE_SECURITY_UPDATES=true
