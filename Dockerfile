FROM debian:bullseye-20230208-slim as builder

WORKDIR /tmp

COPY build-code-gen.sh /tmp

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends ca-certificates curl=7.74.0-1.3+deb11u5 git=1:2.30.2-1 \
        maven=3.6.3-5 unzip=6.0-26+deb11u1 xz-utils=5.2.5-2.1~deb11u1 zip=3.0-12 \
    && curl -L https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u352-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u352b08.tar.gz \
        | tar -C /tmp -x -z -f - \
    && /tmp/build-code-gen.sh \
    && curl -L https://f004.backblazeb2.com/file/talend-job-builder/tos.txz \
        | tar -C /tmp -x -J -f - \
    && cp code-gen/target/au.org.emii.talend.codegen-7.3.1.jar TOS_DI-20200219_1130-V7.3.1/plugins/ \
    && sed -i 's/\(^osgi\.bundles=.*$\)/\1,au.org.emii.talend.codegen/' TOS_DI-20200219_1130-V7.3.1/configuration/config.ini \
    && curl -L https://github.com/unixgeek/env-to-props/releases/download/0.1.0/env_to_props-0.1.0-linux-x86_64.txz \
        | tar -C /tmp --strip-components 1 -x -J -f -

FROM debian:bullseye-20230208-slim

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends libgtk-3-0=3.24.24-4+deb11u2 xvfb=2:1.20.11-1+deb11u5 \
        openjdk-11-jdk-headless=11.0.18+10-1~deb11u1 maven=3.6.3-5 unzip=6.0-26+deb11u1 dos2unix=7.4.1-1 \
    && groupadd -r talend -g 2000 \
    && useradd -m -r -g talend -u 2000 talend \
    && mkdir /home/talend/target

COPY --from=builder /tmp/TOS_DI-20200219_1130-V7.3.1 /home/talend/TOS
COPY --from=builder /tmp/env-to-props                /home/talend
COPY                build-talend-job.sh              /home/talend
COPY                copy-jar-to-libraries.sh         /home/talend
COPY                install-jar.sh                   /home/talend
COPY                run_template.sh                  /home/talend
RUN chmod -R 0777 /home/talend

USER talend

ENTRYPOINT ["/home/talend/build-talend-job.sh"]
