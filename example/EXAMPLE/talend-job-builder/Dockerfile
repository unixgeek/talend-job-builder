FROM talend-job-builder:latest as builder

ARG JOB_NAME=Hello_World
ARG CONTEXT_NAME=Default

COPY --chown=talend:talend . /home/talend/source

WORKDIR /home/talend
RUN /home/talend/build-talend-job.sh ${JOB_NAME} -contextName ${CONTEXT_NAME} \
    && cp run_template.sh run.sh \
    && sed -i'' "s/JOB_NAME/${JOB_NAME}/" run.sh \
    && mkdir /tmp/job \
    && cd /tmp/job \
    && unzip /home/talend/target/${JOB_NAME}_Latest.zip \
    && chmod 755 ${JOB_NAME}/${JOB_NAME}_run.sh \
    && dos2unix ${JOB_NAME}/${JOB_NAME}_run.sh

FROM debian:bullseye-20230208-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-11-jre-headless=11.0.18+10-1~deb11u1

COPY --from=builder /tmp/job /job
COPY --from=builder /home/talend/env-to-props /job
COPY --from=builder /home/talend/run.sh /job

RUN chmod 755 /job/env-to-props \
    && chmod 755 /job/run.sh

WORKDIR /job

ENTRYPOINT ["/job/run.sh"]
