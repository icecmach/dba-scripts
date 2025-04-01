# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# Linux Utility Functions and Aliases
alias la='ls -lAh'
alias ll='ls -lh'
alias envs='env | sort'

# PostgreSQL Utility Functions and Aliases
alias pspg='ps -ef | grep postgres'
alias cdata='cd $PGDATA'
alias scd='cd $SCRIPTS_DIR'
alias pgstart='pg_ctl start && echo "PostgreSQL service started!"'
alias pgstop='pg_ctl stop && echo "PostgreSQL service stopped!"'
alias pgstatus='pg_ctl status'
alias pgdiskusage='du -sh $PGDATA'
alias pgmemusage='ps aux | grep postgres | awk '\''{sum+=$6} END {print "Total memory used by PostgreSQL (in KB):", sum/1024 " MB"}'\'''

dash() {
    printf -- '-%0.s' {1..60}
}

# User specific environment and startup programs
. /home/postgres/scripts/setEnv.sh

# Prompt
WHITE='\[\e[01;37m\]'
RED='\[\e[1;31m\]'
DEFAULT='\[\e[0m\]'
#export PS1=${RED}$(whoami)'@${HOSTNAME}'${WHITE}'[${ORACLE_SID}]($PWD):'
export PS1="${RED}\u@\h${DEFAULT}(\w)$ "

echo -e "\n==================== PostgreSQL System Info ===================="
echo -e "\nPostgreSQL Service Status:"
pgstatus && dash
echo -e "\nPGData Usage:"
pgdiskusage && dash
echo -e "\nMemory Usage (PostgreSQL):"
pgmemusage
echo -e "\n==================== End of PostgreSQL Info ===================="
