FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install --no-install-recommends --yes vim ca-certificates netcat iputils-ping curl

ENTRYPOINT ["tail", "-f", "/dev/null"]