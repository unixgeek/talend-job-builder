#!/bin/sh -e

SELF=$(basename "${0}")

if [ "${JOB_NAME}x" != "Generate_Datax" ]; then
  echo "${SELF}: No setup required."
  exit 0
fi

echo "${SELF}: Installing jar for Generate_Data"
/home/talend/install-jar.sh /home/talend/TOS org.talend.libraries OneWireAPI 6.0.0