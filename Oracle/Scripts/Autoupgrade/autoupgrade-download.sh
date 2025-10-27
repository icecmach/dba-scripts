#!/bin/bash

export JAVA_HOME=$ORACLE_HOME/jdk
export PATH=$PATH:$JAVA_HOME/bin

if [ ! -f "/home/oracle/autoupgrade.jar" ]; then
    wget https://download.oracle.com/otn-pub/otn_software/autoupgrade.jar -P /home/oracle
fi

java -jar /home/oracle/autoupgrade.jar -config /home/oracle/autoupgrade/patch_Download.cfg -patch -mode download