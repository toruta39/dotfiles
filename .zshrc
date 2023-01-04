#
# .zshrc
#
# @author Jeff Geerling
#

# Colors.
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Custom $PATH with extra locations.
export PATH=$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:/usr/local/git/bin:$HOME/.composer/vendor/bin:$PATH

export SVN_EDITOR="vim"
export GIT_EDITOR="vim"
export EDITOR="vim"
export VISUAL="vim"

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

# Set architecture-specific brew share path.
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
    share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
    share_path="/opt/homebrew/share"
else
    echo "Unknown architecture: ${arch_name}"
fi

# Allow history search via up/down keys.
source ${share_path}/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Completions.
autoload -Uz compinit && compinit
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a branch."
     return 0
 fi

 BRANCHES=$(git branch --list $1)
 if [ ! "$BRANCHES" ] ; then
    echo "Branch $1 does not exist."
    return 0
 fi

 git checkout "$1" && \
 git pull upstream "$1" && \
 git push origin "$1"
}

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
dockrun() {
 docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

# Allow Composer to use almost as much RAM as Chrome.
export COMPOSER_MEMORY_LIMIT=-1

# Ask for confirmation when 'prod' is in a command string.
#prod_command_trap () {
#  if [[ $BASH_COMMAND == *prod* ]]
#  then
#    read -p "Are you sure you want to run this command on prod [Y/n]? " -n 1 -r
#    if [[ $REPLY =~ ^[Yy]$ ]]
#    then
#      echo -e "\nRunning command \"$BASH_COMMAND\" \n"
#    else
#      echo -e "\nCommand was not run.\n"
#      return 1
#    fi
#  fi
#}
#shopt -s extdebug
#trap prod_command_trap DEBUG

# asdf
. $(brew --prefix)/opt/asdf/libexec/asdf.sh

# go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# android sdk
export ANDROID_HOME=${HOME}/Library/Android/sdk
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/tools/bin
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

# jdk
if [[ "$OSTYPE" == "darwin"* ]]; then
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-15.jdk/Contents/Home
else
  # Ubuntu
  export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
fi
export PATH=${PATH}:${JAVA_HOME}/bin

# gcloud
if [[ "$OSTYPE" == "darwin"* ]]; then
  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"; fi
  # The next line enables shell command completion for gcloud.
  if [ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]; then source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"; fi
fi

ulimit -n 1200

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="ag --hidden --ignore .git -f --depth 5 -g ''"

# wsl docker
if [ ! -z $WSL_DISTRO_NAME ]; then
  # export DOCKER_HOST="tcp://localhost:2375"
fi

# direnv
eval "$(direnv hook zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(${HOME}/anaconda3/bin/conda 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# spaceship
source $(brew --prefix)/opt/spaceship/spaceship.zsh
