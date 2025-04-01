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

# Create directories
mkdir -p /home/postgres/scripts
chown -R postgres:postgres /home/postgres
usermod -d /home/postgres postgres

mkdir /usr/local/pgsql
chown postgres /usr/local/pgsql

# Initialize db
su - postgres -c 'pg_ctl -D /usr/local/pgsql/data initdb'

# Prepare postgres user environment
cp setEnv.sh /home/postgres/scripts
cp -f -p .bash_profile /home/postgres

# Set permissions
chown -R postgres:postgres /home/postgres
chmod u+x /home/postgres/scripts/*.sh
