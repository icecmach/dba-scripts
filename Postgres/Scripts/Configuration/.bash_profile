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
alias pgstart='pg_ctl start'
alias pgstop='pg_ctl stop'
alias pgstatus='pg_ctl status'
alias pgdiskusage='du -sh $PGDATA'
alias pgmemusage='ps aux | grep postgres | awk '\''{sum+=$6} END {print "Total memory used by PostgreSQL (in KB):", sum/1024 " MB"}'\'''

dash() {
    printf -- '-%0.s' {1..60}
}

# User specific environment and startup programs
. $HOME/scripts/setEnv.sh

# Prompt
WHITE='\[\e[01;37m\]'
RED='\[\e[1;31m\]'
DEFAULT='\[\e[0m\]'
#export PS1=${RED}$(whoami)'@${HOSTNAME}'${WHITE}'[${ORACLE_SID}]($PWD):'
export PS1="${RED}\u@\h${DEFAULT}(\w)$ "

echo "==================== PostgreSQL System Info ===================="
echo "PostgreSQL Service Status: $(pgstatus && dash)"
echo "PGData Usage: $(pgdiskusage && dash)"
echo "Memory Usage: $(pgmemusage)"
echo "==================== End of PostgreSQL Info ===================="
