#!/bin/bash

# Configure Cased Shell for Heroku
export CASED_SHELL_PORT=$PORT
export CASED_SHELL_TLS=off
: ${CASED_SHELL_LOG_LEVEL:="error"}
let SSH_PORT=PORT+1 ;
export CASED_SHELL_OAUTH_UPSTREAM=localhost:$SSH_PORT

PORT=$SSH_PORT /bin/heroku-ssh heroku http://localhost:$PORT bash -i &
python -u run.py --logging=$CASED_SHELL_LOG_LEVEL &

wait -n