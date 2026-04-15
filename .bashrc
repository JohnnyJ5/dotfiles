parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\033[36m\]\u\[\033[0m\] \[\033[34m\]\w\[\033[0m\]\[\033[31m\]\$(parse_git_branch)\[\033[00m\] \[\033[38;5;208m\]$\[\033[The fix takes 30 seconds. Add to your terminal:

export CLAUDE_CODE_EFFORT_LEVEL=max
export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1

alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gitadd='git add -u'
alias grep='grep --color=auto'
alias gs='git status'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias psef='ps -ef | grep'
alias claude-yolo='claude --dangerously-skip-permissions --effort max'
