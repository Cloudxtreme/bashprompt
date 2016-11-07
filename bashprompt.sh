# Better bash prompt, Pascal Sommer 2016

# Credit to:
# https://coderwall.com/p/pn8f0g/show-your-git-status-and-branch-in-color-at-the-command-prompt
# http://jakemccrary.com/blog/2015/05/03/put-the-last-commands-run-time-in-your-bash-prompt/


RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[1;32m"
OCHRE="\033[38;5;95m"
BLUE="\033[1;34m"
WHITE="\033[0;37m"

RESET="\033[0m"


# ADJUST SETTINGS HERE

USER_COLOR=$BLUE
ROOT_COLOR=$RED
HOST_COLOR=$BLUE



function user_color {
    if [ "$(id -u)" != "0" ]; then
        echo -e $USER_COLOR   # normal user
    else
        echo -e $ROOT_COLOR   # root user
    fi
}

function git_color {
    local git_status="$(git status 2> /dev/null)"

    if [[ ! $git_status =~ "working tree clean" ]]; then
        echo -e $RED
    elif [[ $git_status =~ "Your branch is ahead of" ]]; then
        echo -e $YELLOW
    elif [[ $git_status =~ "nothing to commit" ]]; then
        echo -e $GREEN
    else
        echo -e $OCHRE
    fi
}

function git_branch {
    local git_status="$(git status 2> /dev/null)"
    local on_branch="On branch ([^${IFS}]*)"
    local on_commit="HEAD detached at ([^${IFS}]*)"
    
    if [[ $git_status =~ $on_branch ]]; then
        local branch=${BASH_REMATCH[1]}
        echo "($branch)"
    elif [[ $git_status =~ $on_commit ]]; then
        local commit=${BASH_REMATCH[1]}
        echo "($commit)"
    fi
}

# calculate run time of last command

function timer_start {
  timer=${timer:-$SECONDS}
}

function timer_stop {
  timer_show=$(($SECONDS - $timer))
  unset timer
}

trap 'timer_start' DEBUG

if [ "$PROMPT_COMMAND" == "" ]; then
  PROMPT_COMMAND="timer_stop"
else
  PROMPT_COMMAND="$PROMPT_COMMAND; timer_stop"
fi


# combining the prompt

PS1="(\${timer_show}s)"         # run time of last command
PS1+=" "
PS1+="\[\$(user_color)\]\u"     # prints username in color configured above
PS1+="\[$RESET\]@"
PS1+="\[$HOST_COLOR\]\H"        # prints hostname in color configured above
PS1+="\[$RESET\]"
PS1+=" "
PS1+="\[\$(git_color)\]"        # colors git status
PS1+="\$(git_branch)"           # prints current branch
PS1+="\[$RESET\]"
PS1+=" "
PS1+="\w "                      # working dir
PS1+="\\$ "                     # '#' for root, '$' for normal user

export PS1

unset USER_COLOR
unset ROOT_COLOR
unset HOST_COLOR


# PS1='(${timer_show}s)\[\e[1;34m\]\u\[\e[0m\]@\[\e[1;34m\]\H\[\e[0m\] \[\e[1;36m\]($(parse_git_branch))\[\e[0m\] \w \$ '

