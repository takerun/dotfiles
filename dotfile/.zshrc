### ls color
alias ls='ls -G'


### Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"


### prompt format with https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
setopt PROMPT_SUBST ; PS1='[%F{cyan}%n%f %F{green}%c%f]%F{red}$(__git_ps1 "(%s)")%f %# '


### newline next to command results
add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}
precmd() { add_newline }


### targz not including ._ and .DS_Store
tgz() {
  env COPYFILE_DISABLE=1 tar zcvf $1 --exclude=".DS_Store" ${@:2}
}


### uv
# enable completion
if type uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
fi
if type uvx &>/dev/null; then
  eval "$(uvx --generate-shell-completion zsh)"
fi


### nvm
export NVM_DIR=$HOME/.nvm
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . $(brew --prefix)/opt/nvm/nvm.sh


### Rust
export CARGO_HOME=$HOME/.cargo
export RUSTUP_HOME=$HOME/.rustup
export PATH="$CARGO_HOME/bin:$PATH"
# enable completion
if type cargo &>/dev/null; then
  ln -fs "$RUSTUP_HOME/toolchains/stable-aarch64-apple-darwin/share/zsh/site-functions/_cargo" "$HOME/.local/completion/"
fi
if type rustup &>/dev/null; then
  rustup completions zsh > $HOME/.local/completion/_rustup
fi


### zsh_completions zsh_autosuggestions
FPATH=$HOME/.local/completion:$FPATH
if type brew &>/dev/null; then
  chmod -R 755 $(brew --prefix)/share
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
autoload -Uz compinit && compinit
