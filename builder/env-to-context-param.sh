#!/bin/sh -e
# Iterate over environment variables prefixed with CONTEXT_, drop the prefix, use the remaining text as the key,
# and take the value as is. This is then passed to the talend job.
#
# Example
# CONTEXT_user=app1 becomes --context_param=user=appp1

CONTEXT_PARAMS=$(printenv | grep ^CONTEXT_ | tr '\n' ';')
IFS=";"
for PARAM in ${CONTEXT_PARAMS}; do
  KEY=$(echo "${PARAM}" | cut -d '=' -f 1 | sed 's/^CONTEXT_//')
  VALUE="$(echo "${PARAM}" | cut -d '=' -f 2)"
  ARGS="${ARGS}--context_param=${KEY}=${VALUE};"
done

# shellcheck disable=SC2086
exec ./"${1}" ${ARGS} "$@"
