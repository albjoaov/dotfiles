# NVM path management from ansible BEGIN
. ~/.nvm/nvm.sh
# NVM path management from ansible END
export PYENV_ROOT="${HOME}/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export PATH="${HOME}/.bin:$PATH"
export PATH="${HOME}/.local/bin:$PATH"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
export SDKMAN_OFFLINE_MODE=false
