### This bash configuration file is static and provided by the image
### As such, any edit is ephemeral and won't be available next session.

# Autocompletion
source /opt/git-completion.bash

# Prompt - Git information
source /opt/git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1

# Go environment
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/opt/workspace/go
