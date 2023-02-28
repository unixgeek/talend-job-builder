#!/bin/sh -e

SELF=$(basename "${0}")

if [ $# -ne 5 ]; then
  echo "usage: ${SELF} TALEND_HOME GROUP_ID ARTIFACT_ID VERSION LIBRARY_VERSION"
  exit 1
fi

TALEND_HOME="${1}"
GROUP_ID="${2}"
ARTIFACT_ID="${3}"
VERSION="${4}"
# 6.0.0 for a dependency in the org.talend.libraries without the .jar.
# 6.0.0-SNAPSHOT for a dependency that does not exist in org.talend.libraries and is loaded with tLibraryLoad.
LIBRARY_VERSION="${5}"

# May not work universally. Based on observation.
# From: org.mnode.ical4j ical4j 3.2.9
# To:   org/mnode/ical4j/ical4j/3.2.9/ical4j-3.2.9.jar
JAR_FILE=$(echo "${GROUP_ID}" | tr '.' '/')
JAR_FILE="${TALEND_HOME}/configuration/.m2/repository/${JAR_FILE}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar"

echo "${SELF}: Copying ${ARTIFACT_ID}..."
mvn --batch-mode --quiet org.apache.maven.plugins:maven-install-plugin:3.1.0:install-file \
    -Dfile="${JAR_FILE}" \
    -DgroupId=org.talend.libraries \
    -DartifactId="${ARTIFACT_ID}" \
    -Dversion="${LIBRARY_VERSION}" \
    -Dpackaging=jar \
    -DlocalRepositoryPath="${TALEND_HOME}"/configuration/.m2/repository

echo "${SELF}: tLibraryLoad: Find by name \"${ARTIFACT_ID}.jar\""
