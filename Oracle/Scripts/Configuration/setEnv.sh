# Oracle Settings
export ORACLE_BASE=/u01/app/oracle
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/dbhome_1
export DATA_DIR=/u02/oradata
export SCRIPTS_DIR=/home/oracle/scripts

export TMP=/tmp
export TMPDIR=$TMP

export ORACLE_HOSTNAME=$(hostname)
export ORACLE_SID=cdb1
export ORACLE_UNQNAME=$ORACLE_SID
export PDB_NAME=pdb1

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

# Java
export JAVA_HOME=$ORACLE_HOME/jdk

# Path
export PATH=/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH=$ORACLE_HOME/bin:$PATH:$JAVA_HOME/bin

# Database installation settings
export SOFTWARE_DIR=/u01/software
export DB_SOFTWARE="LINUX.X64_193000_db_home.zip"
# Optional Patching
# 19.25
export OPATCH_FILE="p6880880_190000_Linux-x86-64.zip"
export PATCH_FILE="p36866623_190000_Linux-x86-64.zip"
export PATCH_TOP=$SOFTWARE_DIR/36866623
export PATCH_PATH1=$PATCH_TOP/36912597
export PATCH_PATH2=$PATCH_TOP/36878697
