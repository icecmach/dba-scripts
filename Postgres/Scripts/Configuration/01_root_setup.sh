#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    01_root_setup.sh
#% DESCRIPTION
#%    Root steps before database install
#================================================================
#  HISTORY
#     2024/12/05 : Script creation
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#================================================================
# END_OF_HEADER
#================================================================

# Install postgres
dnf install -y postgresql-server.x86_64

PGHOME=$(echo ~postgres)
# Create script directory
mkdir -p $PGHOME/scripts
chown postgres:postgres $PGHOME/scripts

# Initialize db
su - postgres -c 'pg_ctl -D $HOME/data initdb'

# Prepare postgres user environment
cp setEnv.sh $PGHOME/scripts
cp -f -p .bash_profile $PGHOME

# Set permissions
chown -R postgres:postgres $PGHOME
chmod u+x $PGHOME/scripts/*.sh
