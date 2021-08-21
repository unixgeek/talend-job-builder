#!/bin/sh -e

if [ $# -lt 3 ]; then
    echo "usage: $(basename "${0}") JOB_NAME PROJECT_DIR TARGET_DIR [OPTIONAL_PARAMS]"
    exit 1
fi

set -x

JOB_NAME="${1}"
PROJECT_DIR="${2}"
TARGET_DIR="${3}"

Xvfb &
X_PID=$!
export DISPLAY=:0

/builder/TOS/TOS_DI-linux-gtk-x86_64 \
    -nosplash \
    --launcher.suppressErrors \
    -data /builder/data \
    -application au.org.emii.talend.codegen.Generator \
    -jobName "${JOB_NAME}" \
    -projectDir "${PROJECT_DIR}" \
    -targetDir "${TARGET_DIR}" \
    "$@"

kill $X_PID
wait $X_PID
