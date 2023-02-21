#!/bin/sh -e

if [ $# -lt 1 ]; then
    echo "usage: $(basename "${0}") JOB_NAME [OPTIONAL_PARAMS]"
    exit 1
fi

JOB_NAME="${1}"
shift 1

Xvfb &
export DISPLAY=:0

# Needed so the job can run as a different user id.
HOME=/home/talend

# Run a prebuild script if it exists.
export JOB_NAME
chmod 755 /home/talend/source/talend-job-builder/prebuild-setup.sh || true
/home/talend/source/talend-job-builder/prebuild-setup.sh || true

# If there is a compilation error, it will be in this log file, but the container will
# be destroyed, so it can't be viewed. Tail the log regardless of error so that the compilation
# step can be pid 1.
tail --retry --follow /home/talend/data/.metadata/.log >&2 &

# todo Should be exec.
exec /home/talend/TOS/TOS_DI-linux-gtk-x86_64 \
    -nosplash \
    --launcher.suppressErrors \
    -data /home/talend/data \
    -application au.org.emii.talend.codegen.Generator \
    -jobName "${JOB_NAME}" \
    -projectDir /home/talend/source \
    -targetDir /home/talend/target \
    "$@"