#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    01_19c_root.sh
#% DESCRIPTION
#%    Root steps before database install
#================================================================
#  HISTORY
#     2024/11/10 : Script creation
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#================================================================
# END_OF_HEADER
#================================================================

# Variables
. ./setEnv.sh

# Install dependencies
sh 02_os_dependencies.sh

# Create directories
mkdir -p $ORACLE_HOME
mkdir -p $SOFTWARE_DIR
mkdir -p $DATA_DIR
mkdir -p $SCRIPTS_DIR

# Prepare oracle user environment
cp setEnv.sh $SCRIPTS_DIR
cp start_all.sh $SCRIPTS_DIR
cp stop_all.sh $SCRIPTS_DIR
cp -f -p .bash_profile /home/oracle
chown oracle:oinstall /home/oracle/.bash_profile
mv 03_* 04_* 05_* /home/oracle/scripts

mv $DB_SOFTWARE $SOFTWARE_DIR
mv $OPATCH_FILE $SOFTWARE_DIR
mv $PATCH_FILE $SOFTWARE_DIR

# Set permissions
chown -R oracle:oinstall $SCRIPTS_DIR /u01 /u02
chmod u+x $SCRIPTS_DIR/*.sh

# Install database software
su - oracle -c 'sh /home/oracle/scripts/03_oracle_software_installation.sh'

# Post-install root scripts
echo "******************************************************************************"
echo "Run root scripts." `date`
echo "******************************************************************************"
sh $ORA_INVENTORY/orainstRoot.sh
sh $ORACLE_HOME/root.sh

# Patch install
su - oracle -c 'sh /home/oracle/scripts/04_oracle_software_patch.sh'

# Create database
su - oracle -c 'sh /home/oracle/scripts/05_oracle_create_database.sh'

# Create systemd service
sh 06_oracle_service_setup.sh
