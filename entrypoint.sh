#!/bin/sh -e

if [ $# -lt 1 ]; then
    echo "usage: $(basename "${0}") JOB_NAME [OPTIONAL_PARAMS]"
    exit 1
fi

set -x

JOB_NAME="${1}"
shift 1

Xvfb &
export DISPLAY=:0

# Needed so the job can run as a different user id.
HOME=/home/talend
export PATH="${HOME}/maven/bin:${PATH}"

/home/talend/TOS/TOS_DI-linux-gtk-x86_64 \
    -nosplash \
    --launcher.suppressErrors \
    -data /home/talend/data \
    -application au.org.emii.talend.codegen.Generator \
    -jobName "${JOB_NAME}" \
    -projectDir /home/talend/source \
    -targetDir /home/talend/target \
    "$@" || (cat /home/talend/data/.metadata/.log && exit 1)
