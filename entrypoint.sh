#!/bin/bash

if [ -z "$CASED_SHELL_SECRET" ]; then
  echo "CASED_SHELL_SECRET required"
  exit 1
fi

# Configure Cased Shell for Heroku
export CASED_SHELL_PORT=$PORT
export CASED_SHELL_TLS=off
export CASED_SHELL_PLUGINS="approval"
export CASED_SHELL_APPROVALS="does-not-exist"

: ${CASED_SHELL_LOG_LEVEL:="error"}
let HEROKU_SSH_PORT=PORT+1 ;
export CASED_SHELL_OAUTH_UPSTREAM=localhost:$HEROKU_SSH_PORT

echo "starting ssh server"
PORT=$HEROKU_SSH_PORT /bin/heroku-ssh heroku https://$CASED_SHELL_HOSTNAME bash -i &

echo "parsing jump config"
ONCE=true /bin/jump /jump.yml /tmp/jump.json
sed -i "s/\$HEROKU_APP_NAME/$HEROKU_APP_NAME/g" /tmp/jump.json
jq --arg placeholder \$HEROKU_SSH_PORT --arg port $HEROKU_SSH_PORT \
  '.prompts | map((select(.port == $placeholder) | .port) |= $port) | { prompts: .}' \
    /tmp/jump.json > /tmp/prompts.json
export CASED_SHELL_HOST_FILE=/tmp/prompts.json

echo "starting cased shell server"
python -u run.py --logging=$CASED_SHELL_LOG_LEVEL &
ps axjf
wait -n