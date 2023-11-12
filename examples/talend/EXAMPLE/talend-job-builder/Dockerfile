FROM talend-job-builder:latest as builder

ARG JOB_NAME=Hello_World
ARG CONTEXT_NAME=Default

COPY --chown=talend:talend . /home/talend/source

WORKDIR /home/talend

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN /home/talend/build-talend-job.sh ${JOB_NAME} -contextName ${CONTEXT_NAME} \
    && cp run-wrapper.sh run.sh \
    && sed -i'' "s/JOB_NAME/${JOB_NAME}/" run.sh \
    && unzip /home/talend/target/${JOB_NAME}_Latest.zip -d /tmp/job \
    && chmod 755 /tmp/job/${JOB_NAME}/${JOB_NAME}_run.sh \
    && dos2unix /tmp/job/${JOB_NAME}/${JOB_NAME}_run.sh \
    && MODULES=$(jdeps --multi-release 11 --ignore-missing-deps --print-module-deps /tmp/job/${JOB_NAME}/*.jar /tmp/job/lib/*.jar) \
    && jlink --add-modules "${MODULES},jdk.crypto.ec" --no-header-files --no-man-pages --output /tmp/runtime

FROM debian:bookworm-20231030-slim

COPY --from=builder /tmp/runtime        /runtime
COPY --from=builder /tmp/job            /job
COPY --from=builder /home/talend/run.sh /job

# These two are optional and depends on your needs. You should not need both.
COPY --from=builder --chmod=0755 /home/talend/env-to-props            /job
COPY --from=builder --chmod=0755 /home/talend/env-to-context-param.sh /job

ENV PATH=$PATH:/runtime/bin
WORKDIR /job

ENTRYPOINT ["/job/run.sh"]
