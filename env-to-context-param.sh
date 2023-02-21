#!/bin/bash -e
# todo no bash

CONTEXT_PARAMS=$(printenv | grep ^CONTEXT_)
#IFS=$'\n' # todo POSIX?
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

for PARAM in ${CONTEXT_PARAMS}; do
  KEY=$(echo "${PARAM}" | cut -d '=' -f 1 | sed 's/^CONTEXT_//')
  VALUE="$(echo "${PARAM}" | cut -d '=' -f 2)"
  ARGS="${ARGS} --context_param=${KEY}=\"${VALUE}\""
done
IFS=$SAVEIFS
echo "${ARGS}"

# todo doesn't work "" seems to send them as a literal, without them, values with spaces get mangled.
# todo can this work with an array?