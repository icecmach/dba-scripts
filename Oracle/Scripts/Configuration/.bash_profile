# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

alias sdba='sqlplus / as sysdba'
alias sq='sql / as sysdba'
alias rmant='rman target /'
alias pora='ps -ef | grep pmon'
alias orab='cd $ORACLE_BASE'
alias orah='cd $ORACLE_HOME'
alias orad='cd $DATA_DIR'
alias scd='cd $SCRIPTS_DIR'
alias ctns='cd $ORACLE_HOME/network/admin'
alias la='ls -lAh'
alias ll='ls -lh'
alias envs='env | sort'

# User specific environment and startup programs
. /home/oracle/scripts/setEnv.sh

#
WHITE='\[\e[01;37m\]'
RED='\[\e[1;31m\]'
DEFAULT='\[\e[0m\]'
#export PS1=${RED}$(whoami)'@${HOSTNAME}'${WHITE}'[${ORACLE_SID}]($PWD):'
export PS1="${RED}\u@\h${DEFAULT}[${ORACLE_SID}](\w)$ "
