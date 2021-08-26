FROM debian:bullseye-slim as builder

WORKDIR /tmp

COPY build-code-gen.sh /tmp

RUN apt-get update \
    && apt-get -y upgrade \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends git maven zip unzip curl ca-certificates \
    && curl -L https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_linux_8u292b10.tar.gz \
        | tar -C /tmp -x -z -f - \
    # Tried to pipe, but no joy.  7z x -si -tzip
    && curl -OL https://sourceforge.net/projects/talend-studio/files/Talend%20Open%20Studio/7.3.1/TOS_DI-20200219_1130-V7.3.1.zip/download \
    && unzip -q download \
    && /tmp/build-code-gen.sh \
    && cp code-gen/target/au.org.emii.talend.codegen-7.3.1.jar TOS_DI-20200219_1130-V7.3.1/plugins/ \
    && sed -i 's/\(^osgi\.bundles=.*$\)/\1,au.org.emii.talend.codegen/' TOS_DI-20200219_1130-V7.3.1/configuration/config.ini

FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get -y upgrade \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends git libgtk-3-dev openjdk-11-jdk-headless xvfb \
    && mkdir /builder \
    && groupadd -r talend \
    && useradd -m -r -g talend talend # HOME is needed by Talend \
    && mkdir /home/talend/target \
    && chown talend:talend /home/talend/target # Needed for bind mount to be owned by the talend user.

COPY --from=builder /tmp/TOS_DI-20200219_1130-V7.3.1 /builder/TOS
COPY btj.sh /builder/btj.sh
RUN chmod 0755 /builder/btj.sh

USER talend

ENTRYPOINT ["/builder/btj.sh"]