# todo latest
FROM unixgeek2/talend-job-builder:improvements as builder

# todo is there a way to make this more generic?
# todo context will need to come from env variables or be mounted as a volume.

COPY EXAMPLE /home/talend/source

WORKDIR /home/talend
RUN /home/talend/entrypoint.sh Print_Context -contextName NonProd

USER root
RUN apt-get update \
    && apt-get install unzip \
    && mkdir /job \
    && cd /job \
    && unzip /home/talend/target/Print_Context_Latest.zip \
    && chmod 755 Print_Context/Print_Context_run.sh

# todo what is a good base image option? roll our own?
FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-11-jdk-headless
COPY --from=builder /job /job

ENTRYPOINT ["/job/Print_Context/Print_Context_run.sh"]

#FROM gcr.io/distroless/java11-debian11:debug-nonroot

#COPY --from=builder /job /job
# todo what should this really be?
#ENTRYPOINT ["/job/Print_Context/Print_Context_run.sh"]