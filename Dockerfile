FROM debian:bullseye-slim as builder

WORKDIR /tmp

COPY build-code-gen.sh /tmp

RUN apt-get update \
    && apt-get -y upgrade \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends git zip unzip curl ca-certificates maven \
    && curl -L https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u352-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u352b08.tar.gz \
        | tar -C /tmp -x -z -f - \
    # Tried to pipe, but no joy.  7z x -si -tzip
    && curl -OL https://sourceforge.net/projects/talend-studio/files/Talend%20Open%20Studio/7.3.1/TOS_DI-20200219_1130-V7.3.1.zip/download \
    && unzip -q download
# temporary to get around maven timeout issues.
RUN /tmp/build-code-gen.sh \
    && cp code-gen/target/au.org.emii.talend.codegen-7.3.1.jar TOS_DI-20200219_1130-V7.3.1/plugins/ \
    && sed -i 's/\(^osgi\.bundles=.*$\)/\1,au.org.emii.talend.codegen/' TOS_DI-20200219_1130-V7.3.1/configuration/config.ini \
    && curl -L https://dlcdn.apache.org/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz \
        | tar -C /tmp -x -z -f -

FROM debian:bullseye-slim

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends libgtk-3-0 xvfb openjdk-11-jdk \
    && groupadd -r talend -g 2000 \
    && useradd -m -r -g talend -u 2000 talend \
    && mkdir /home/talend/target

COPY --from=builder --chown=talend:talend /tmp/TOS_DI-20200219_1130-V7.3.1 /home/talend/TOS
COPY --from=builder --chown=talend:talend /tmp/apache-maven-3.5.4          /home/talend/maven
COPY --chown=talend:talend entrypoint.sh /home/talend/entrypoint.sh
RUN chmod -R 0777 /home/talend

USER talend

ENTRYPOINT ["/home/talend/entrypoint.sh"]