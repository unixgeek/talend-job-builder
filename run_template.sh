#!/bin/sh -e

if [ -n "${CONTEXT}" ]; then
  ./env-to-props "${CONTEXT}"
fi

cd JOB_NAME

if ! grep -q exec JOB_NAME_run.sh; then
  echo "WARN: shell script should have \"exec java ...\" for proper signal handling"
  echo "See https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example"
fi

exec ./JOB_NAME_run.sh