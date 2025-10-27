#!/bin/bash

export JAVA_HOME=$ORACLE_HOME/jdk
export PERL5LIB=$ORACLE_HOME/perl/lib
export PATH=$PATH:$JAVA_HOME/bin:$ORACLE_HOME/perl/bin

if [ ! -f "/u01/autoupgrade/patches/LINUX.X64_193000_db_home.zip" ]; then
    cp /vagrant/LINUX.X64_193000_db_home.zip /u01/autoupgrade/patches/
fi

java -jar /home/oracle/autoupgrade.jar -config /home/oracle/autoupgrade/patch_Deploy.cfg -patch -mode deploy

# Run as root
#/u01/app/oracle/product/19.28/dbhome_1/root.sh