#!/bin/bash -e

OUT=${STDOUT:-/var/log/stdout.log}
ERR=${STDERR:-/var/log/stderr.log}

cd "$(dirname "${0}")"
ROOT_PATH=$(pwd)
exec java -Dtalend.component.manager.m2.repository="${ROOT_PATH}"/../lib \
    ${talend.job.jvmargs} \
    -cp ${talend.job.sh.classpath} \
    ${talend.job.class} ${talend.job.sh.addition} "$@" > >(tee "${OUT}") 2> >(tee "${ERR}" >&2)