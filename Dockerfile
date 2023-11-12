FROM debian:bookworm-20231030-slim as code-gen-builder

WORKDIR /tmp

COPY code-gen/build-code-gen.sh /tmp

# Needed for sdkman.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils zip \
    && curl -s https://get.sdkman.io | bash \
    && source /root/.sdkman/bin/sdkman-init.sh \
    && sdk install maven 3.9.5 \
    && sdk install java 8.0.392-tem \
    && /tmp/build-code-gen.sh \
    && curl -L https://f004.backblazeb2.com/file/talend-job-builder/tos.txz \
        | tar -C /tmp -x -J -f - \
    && cp code-gen/target/au.org.emii.talend.codegen-7.3.1.jar TOS_DI-20200219_1130-V7.3.1/plugins/ \
    && sed -i 's/\(^osgi\.bundles=.*$\)/\1,au.org.emii.talend.codegen/' TOS_DI-20200219_1130-V7.3.1/configuration/config.ini

FROM rust:1.73.0-slim-bookworm as app-builder

RUN mkdir /app
COPY builder/env-to-props/src        /app/src
COPY builder/env-to-props/Cargo.toml /app
COPY builder/env-to-props/Cargo.lock /app
WORKDIR /app
RUN cargo build --release

FROM debian:bookworm-20231030-slim

# Needed for sdkman.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV SDKMAN_DIR=/usr/local/sdkman
ENV PATH=$PATH:$SDKMAN_DIR/candidates/java/current/bin:$SDKMAN_DIR/candidates/maven/current/bin

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl dos2unix libgtk-3-0 unzip xvfb zip \
    && curl -s https://get.sdkman.io?rcupdate=false | bash \
    && source $SDKMAN_DIR/bin/sdkman-init.sh \
    && sdk install maven 3.9.5 \
    && sdk install java 11.0.21-tem \
    && apt-get purge -y ca-certificates curl \
    && mkdir -m 0777 /home/talend /home/talend/TOS \
    && groupadd talend -g 2000 \
    && useradd -g talend -u 2000 talend

COPY --from=code-gen-builder --chmod=0777 /tmp/TOS_DI-20200219_1130-V7.3.1 /home/talend/TOS
COPY --from=app-builder /app/target/release/env-to-props /home/talend

COPY talend/copy-dependency-to-talend-libraries.sh /home/talend
COPY talend/install-dependency-from-local.sh       /home/talend
COPY talend/install-dependency-from-repo.sh        /home/talend

COPY builder/build-talend-job.sh     /home/talend
COPY builder/run-wrapper.sh          /home/talend
COPY builder/env-to-context-param.sh /home/talend

WORKDIR /home/talend
USER talend

ENTRYPOINT ["/home/talend/build-talend-job.sh"]
