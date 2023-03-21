#!/bin/sh -e
# Install a local jar file to the talend maven repository.

SELF=$(basename "${0}")

if [ $# -ne 4 ]; then
  echo "usage: ${SELF} TALEND_HOME ARTIFACT_ID LIBRARY_VERSION JAR_FILE"
  exit 1
fi

TALEND_HOME="${1}"
ARTIFACT_ID="${2}"
# 6.0.0 for a dependency in the org.talend.libraries without the .jar.
# 6.0.0-SNAPSHOT for a dependency that does not exist in org.talend.libraries and is loaded with tLibraryLoad.
LIBRARY_VERSION="${3}"
JAR_FILE="${4}"

echo "${SELF}: Installing ${JAR_FILE}..."
mvn --batch-mode --quiet org.apache.maven.plugins:maven-install-plugin:3.1.0:install-file \
    -Dfile="${JAR_FILE}" \
    -DgroupId=org.talend.libraries \
    -DartifactId="${ARTIFACT_ID}" \
    -Dversion="${LIBRARY_VERSION}" \
    -Dpackaging=jar \
    -DlocalRepositoryPath="${TALEND_HOME}"/configuration/.m2/repository

echo "${SELF}: tLibraryLoad: Find by name \"${ARTIFACT_ID}.jar\""
