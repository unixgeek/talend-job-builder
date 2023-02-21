#!/bin/sh -e

SELF=$(basename "${0}")

if [ $# -ne 4 ]; then
  echo "usage: ${SELF} TALEND_HOME GROUP_ID ARTIFACT_ID VERSION"
  exit 1
fi

TALEND_HOME="${1}"
GROUP_ID="${2}"
ARTIFACT_ID="${3}"
VERSION="${4}"

# Talend Nexus Repository: https://talend-update.talend.com

echo "${SELF}: Installing ${ARTIFACT_ID}..."
mvn --batch-mode --quiet org.apache.maven.plugins:maven-dependency-plugin:3.5.0:get \
    -Dmaven.repo.local="${TALEND_HOME}"/configuration/.m2/repository \
    -DgroupId="${GROUP_ID}" \
    -DartifactId="${ARTIFACT_ID}" \
    -Dversion="${VERSION}" \
    -DremoteRepositories=https://talend-update.talend.com/nexus/content/repositories/libraries/
