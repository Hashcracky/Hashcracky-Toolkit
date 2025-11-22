# GO BUILD LAYER
# Dependencies:
# - git for fetching repos
FROM golang:alpine AS gobuild
RUN mkdir -p /src/app && \
    apk update && apk add --no-cache git
WORKDIR /src/app

RUN git clone https://github.com/hashcracky/ptt && \
    cd ptt && go build .

# C BUILD LAYER
# Dependencies:
# - git for fetching repos
# - build-base for compiling binaries
# - judy-dev for rulechef & rulecat
FROM alpine AS cbuild
RUN mkdir -p /src/compile && \
    apk update && apk add --no-cache git build-base judy-dev
WORKDIR /src/compile

RUN git clone https://github.com/hashcat/hashcat-utils && \
    git clone https://github.com/Cynosureprime/rulechef && \
    git clone https://github.com/Cynosureprime/rulecat && \
    make -C /src/compile/hashcat-utils && \
    make -C /src/compile/rulechef && \
    make -C /src/compile/rulecat

# RUN LAYER
# Dependencies:
# - tini for container entrypoint
# - build-base judy-dev rulechef & rulecat
# - perl for hashcat-util scripts
# - bind-tools for ptt
FROM alpine
RUN addgroup --gid 10001 --system nonroot \
    && adduser  --uid 10000 --system --ingroup nonroot --home /home/nonroot nonroot; \
    apk update; apk add --no-cache tini build-base judy-dev perl bind-tools

COPY --from=cbuild /src/compile/rulechef/rulechef /bin/rulechef
COPY --from=cbuild /src/compile/rulecat/rulecat /bin/rulecat
COPY --from=cbuild /src/compile/hashcat-utils/bin/*.bin /bin/
COPY --from=cbuild /src/compile/hashcat-utils/src/*.pl /bin/
COPY --from=gobuild /src/app/ptt/ptt /bin/ptt

COPY /scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /data
USER nonroot

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh"]

