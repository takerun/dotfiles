### zsh_completions
if type brew &>/dev/null; then
  chmod -R go-w $(brew --prefix)/share/zsh
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit && compinit
fi


### ls color
alias ls='ls -G'


### git command settings
# display of command results
#source /usr/local/etc/bash_completion.d/git-prompt.sh
#source /usr/local/etc/bash_completion.d/git-completion.bash
#GIT_PS1_SHOWDIRTYSTATE=true
#export PS1='\[\033[37m\][\[\033[36m\]\u \[\033[32m\]\W\[\033[37m\]]\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '


### pyenv settings
# enable completion
if type pyenv &>/dev/null; then
  eval "$(pyenv init -)";
fi
# enable singleton resource folder (shims and versions)
# pyenvのデフォルトではリソースを~/.pyenvに入れる
# export PYENV_ROOT=/usr/local/var/pyenv

### poetry settings
#export PATH=$HOME/.poetry/bin:$PATH
# enable completion
#if which poetry > /dev/null; then
#  poetry completions bash > $(brew --prefix)/etc/bash_completion.d/poetry.bash-completion
#fi

### java settings
# 1.8.1: -v "1.8"
# 10.0.1: -v "10.0"
#export JAVA_HOME=$(/System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/java_home -v "1.8")
#export PATH=${JAVA_HOME}/bin:${PATH}


# Rust
export CARGO_HOME=~/Library/Rust/.cargo
export RUSTUP_HOME=~/Library/Rust/.rustup
export PATH="$CARGO_HOME/bin:$PATH"
