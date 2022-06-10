#!/bin/sh -e

if [ "$(basename "${0}")" != "btj.sh" ]; then
    exec "$@"
fi

if [ $# -lt 3 ]; then
    echo "usage: $(basename "${0}") JOB_NAME GIT_URL GIT_BRANCH [OPTIONAL_PARAMS]"
    exit 1
fi

set -x

# todo specify branch or tag on url?
JOB_NAME="${1}"
GIT_URL="${2}"
GIT_BRANCH="${3}"
shift 3

#git clone --depth 1 --branch "${GIT_BRANCH}" "${GIT_URL}" "${HOME}"/source

Xvfb &
X_PID=$!
export DISPLAY=:0

"${HOME}"/TOS/TOS_DI-linux-gtk-x86_64 \
    -nosplash \
    --launcher.suppressErrors \
    -data "${HOME}"/data \
    -application au.org.emii.talend.codegen.Generator \
    -jobName "${JOB_NAME}" \
    -projectDir "${HOME}"/source \
    -targetDir "${HOME}"/target \
    "$@"

kill $X_PID
wait $X_PID
