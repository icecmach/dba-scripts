#!/bin/ksh
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#================================================================

rm ora-install.zip
tar -cvf ora-install.tar 0*.sh s*.sh .bash_profile dbora.service
cp ora-install.tar ~/oracle-vagrant/linux/ol9_clean/software
