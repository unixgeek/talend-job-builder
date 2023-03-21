#!/bin/sh -e
# Shell script template to be set in the Talend workspace.

cd "$(dirname "${0}")"
ROOT_PATH=$(pwd)
exec java -Dtalend.component.manager.m2.repository="${ROOT_PATH}"/../lib \
    ${talend.job.jvmargs} \
    -cp ${talend.job.sh.classpath} \
    ${talend.job.class} ${talend.job.sh.addition} "$@"
