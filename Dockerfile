FROM debian:buster-slim as builder

WORKDIR /root

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends git maven zip unzip curl \
    && curl -L https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_linux_8u292b10.tar.gz \
        | tar -C /root -x -z -f - \
    # Tried to pipe, but no joy.  7z x -si -tzip
    && curl -OL https://sourceforge.net/projects/talend-studio/files/Talend%20Open%20Studio/7.3.1/TOS_DI-20200219_1130-V7.3.1.zip/download \
    && unzip -q download

COPY build-code-gen.sh /root
RUN /root/build-code-gen.sh

RUN cp code-gen/target/au.org.emii.talend.codegen-7.3.1.jar TOS_DI-20200219_1130-V7.3.1/plugins/ \
    && sed -i 's/\(^osgi\.bundles=.*$\)/\1,au.org.emii.talend.codegen/' TOS_DI-20200219_1130-V7.3.1/configuration/config.ini

FROM debian:buster-slim

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends git libgtk-3-dev openjdk-11-jdk-headless xvfb \
    && mkdir -p /builder

COPY --from=builder /root/TOS_DI-20200219_1130-V7.3.1 /builder/TOS
COPY btj.sh /builder/btj.sh
RUN chmod 755 /builder/btj.sh
