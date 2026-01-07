# GO BUILD LAYER
# Dependencies:
# - git for fetching repos
FROM golang:alpine AS gobuild
RUN mkdir -p /src/app && \
    apk update && apk add --no-cache git
WORKDIR /src/app

RUN git clone https://github.com/hashcracky/ptt && \
    git clone https://github.com/hashcracky/brainstorm && \
    cd /src/app/ptt && go build . && \
    cd /src/app/brainstorm && go build .

# C BUILD LAYER
# Dependencies:
# - git for fetching repos
# - build-base for compiling binaries
# - judy-dev for rulechef & rulecat
FROM alpine AS cbuild
RUN mkdir -p /src/compile && \
    apk update && apk add --no-cache git build-base judy-dev cmake
WORKDIR /src/compile

RUN git clone https://github.com/hashcat/hashcat-utils && \
    git clone https://github.com/Cynosureprime/rulechef && \
    git clone https://github.com/Cynosureprime/rulecat && \
    git clone https://github.com/0xVavaldi/ruleprocessorY && \
    make -C /src/compile/hashcat-utils && \
    make -C /src/compile/rulechef && \
    make -C /src/compile/rulecat && \
    mkdir -p /src/compile/ruleprocessorY/build && \
    cmake -S /src/compile/ruleprocessorY -B /src/compile/ruleprocessorY/build && \
    cmake --build /src/compile/ruleprocessorY/build

# RUN LAYER
# Dependencies:
# - tini for container entrypoint
# - build-base judy-dev rulechef & rulecat
# - perl for hashcat-util scripts
# - bind-tools for ptt
FROM alpine
RUN apk update; apk add --no-cache tini build-base judy-dev perl bind-tools

COPY --from=cbuild /src/compile/rulechef/rulechef /bin/rulechef
COPY --from=cbuild /src/compile/rulecat/rulecat /bin/rulecat
COPY --from=cbuild /src/compile/hashcat-utils/bin/*.bin /bin/
COPY --from=cbuild /src/compile/hashcat-utils/src/*.pl /bin/
COPY --from=gobuild /src/app/ptt/ptt /bin/ptt
COPY --from=gobuild /src/app/brainstorm/brainstorm /bin/brainstorm
COPY --from=cbuild /src/compile/ruleprocessorY/build/ruleprocessorY /bin/ruleprocessorY

COPY /scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /data

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh"]

