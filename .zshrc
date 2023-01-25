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

# Explicitly use Emacs keymap for zle
bindkey -e

# zplug
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "mafredri/zsh-async", from:"github", use:"async.zsh"
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/kubectl", from:oh-my-zsh
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "spaceship-prompt/spaceship-prompt", use:spaceship.zsh, from:github, as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose

# Better history searching with arrow keys
if zplug check "zsh-users/zsh-history-substring-search"; then
  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down
fi

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

# Run a mysql container
mysqlrun() {
 docker run -d -p 3306:3306 --env MYSQL_USER=mysql --env MYSQL_PASSWORD=mysql --env MYSQL_ALLOW_EMPTY_PASSWORD=yes --env MYSQL_DATABASE=sandbox --name=mysql mysql
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
  if [ -f "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"; fi
  # The next line enables shell command completion for gcloud.
  if [ -f "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]; then source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"; fi
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

# zsh compsys
if [[ -z "$NOMENU" ]] ; then
  zstyle ':completion:*' menu select=2 # if there are more than 5 options allow selecting from a menu
else
  setopt no_auto_menu # don't use any menus at all
fi

# asdf
. $(brew --prefix)/opt/asdf/libexec/asdf.sh
