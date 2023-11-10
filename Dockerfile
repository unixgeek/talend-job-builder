FROM debian:bullseye-20230208-slim as code-gen-builder

WORKDIR /tmp

COPY code-gen/build-code-gen.sh /tmp

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends ca-certificates curl git maven unzip xz-utils zip \
    && curl -L https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u352-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u352b08.tar.gz \
        | tar -C /tmp -x -z -f - \
    && /tmp/build-code-gen.sh \
    && curl -L https://f004.backblazeb2.com/file/talend-job-builder/tos.txz \
        | tar -C /tmp -x -J -f - \
    && cp code-gen/target/au.org.emii.talend.codegen-7.3.1.jar TOS_DI-20200219_1130-V7.3.1/plugins/ \
    && sed -i 's/\(^osgi\.bundles=.*$\)/\1,au.org.emii.talend.codegen/' TOS_DI-20200219_1130-V7.3.1/configuration/config.ini

FROM rust:1.68.0-slim-bullseye as app-builder

RUN mkdir /app
COPY builder/env-to-props/src        /app/src
COPY builder/env-to-props/Cargo.toml /app
COPY builder/env-to-props/Cargo.lock /app
WORKDIR /app
RUN cargo build --release

FROM debian:bullseye-20230208-slim

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends libgtk-3-0 xvfb openjdk-11-jdk-headless maven unzip dos2unix \
    && mkdir -m 0777 /home/talend /home/talend/TOS \
    && groupadd -r talend -g 2000 \
    && useradd -m -r -g talend -u 2000 talend

COPY --from=code-gen-builder --chmod=0777 /tmp/TOS_DI-20200219_1130-V7.3.1 /home/talend/TOS
COPY --from=app-builder      /app/target/release/env-to-props /home/talend

COPY talend/copy-dependency-to-talend-libraries.sh /home/talend
COPY talend/install-dependency-from-local.sh       /home/talend
COPY talend/install-dependency-from-repo.sh        /home/talend

COPY builder/build-talend-job.sh     /home/talend
COPY builder/run-wrapper.sh          /home/talend
COPY builder/env-to-context-param.sh /home/talend

USER talend

ENTRYPOINT ["/home/talend/build-talend-job.sh"]
