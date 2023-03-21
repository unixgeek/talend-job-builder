#!/bin/sh -e
# This script is executed by build-talend-job.sh before building the talend job, if it exists. If it isn't needed, simply
# delete it. An alternative to installing dependencies per job would be to build an image off of talend-job-builder that
# has all of the dependencies for all of the jobs in the workspace already installed.

SELF=$(basename "${0}")

if [ "${JOB_NAME}x" != "Generate_Datax" ]; then
  echo "${SELF}: No setup required."
  exit 0
fi

echo "${SELF}: Installing jar for Generate_Data"
/home/talend/install-dependency-from-repo.sh /home/talend/TOS org.talend.libraries OneWireAPI 6.0.0