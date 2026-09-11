# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"

c() {
  open -a "Cursor" "${1:-.}"
}

# --- SDKMAN: put current candidates on PATH; lazy-load full init for `sdk` ---
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -d "$SDKMAN_DIR/candidates" ]]; then
  for _sdk_bin in "$SDKMAN_DIR"/candidates/*/current/bin(N); do
    PATH="$_sdk_bin:$PATH"
  done
  unset _sdk_bin
fi
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

# --- oh-my-zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
zstyle ':omz:update' mode disabled
source "$ZSH/oh-my-zsh.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- NVM: default Node on PATH; lazy-load full nvm for `nvm` ---
export NVM_DIR="$HOME/.nvm"
_nvm_bin=
if [[ -r "$NVM_DIR/alias/default" ]]; then
  _nvm_ver="${$(<"$NVM_DIR/alias/default")%%$'\n'*}"
  if [[ -d "$NVM_DIR/versions/node/$_nvm_ver/bin" ]]; then
    _nvm_bin="$NVM_DIR/versions/node/$_nvm_ver/bin"
  fi
fi
# alias may be "node" / "lts/*" — fall back to newest installed version
if [[ -z $_nvm_bin && -d "$NVM_DIR/versions/node" ]]; then
  _nvm_bin=( "$NVM_DIR"/versions/node/*/bin(NOn[1]) )
fi
[[ -n $_nvm_bin ]] && PATH="$_nvm_bin:$PATH"
unset _nvm_bin _nvm_ver

nvm() {
  unset -f nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"
  nvm "$@"
}

# --- grok (PATH + completions only; no second compinit — OMZ already ran it) ---
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
