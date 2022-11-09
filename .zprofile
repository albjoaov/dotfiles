# NVM path management from ansible BEGIN
. ~/.nvm/nvm.sh
# NVM path management from ansible END
source ~/pyenv/.pyenvrc
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export PATH=/Users/joaoalbuquerque/.bin:$PATH
export PATH=/Users/joaoalbuquerque/.local/bin:$PATH

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/joaoalbuquerque/.sdkman"
[[ -s "/Users/joaoalbuquerque/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/joaoalbuquerque/.sdkman/bin/sdkman-init.sh"
export SDKMAN_OFFLINE_MODE=false
