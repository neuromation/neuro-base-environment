#!/usr/bin/env bash

{

if [ ! -z "$EXPOSE_SSH" ]; then
  echo "Starting SSH server"
  /usr/sbin/sshd -e
fi

ldconfig

if [ "$GCP_SERVICE_ACCOUNT_KEY_PATH" ]; then
  gcloud auth activate-service-account --key-file "$GCP_SERVICE_ACCOUNT_KEY_PATH"
fi

if [ -f "$NM_WANDB_TOKEN_PATH" ]; then
  wandb login "$(cat $NM_WANDB_TOKEN_PATH)"
fi

exec "$@"

} 2>&1 | tee $OUTPUT_PIPE
exit "${PIPESTATUS[0]}"
