FROM blacktop/bro

LABEL maintainer "https://github.com/blacktop"

COPY . /go/src/github.com/maliceio/malice-bro
RUN apk --update add --no-cache bro bro-libunrar ca-certificates
RUN apk --update add --no-cache -t .build-deps \
                    build-base \
                    mercurial \
                    musl-dev \
                    openssl \
                    bash \
                    wget \
                    git \
                    gcc \
                    go \
  && echo "Building bro-scan Go binary..." \
  && cd /go/src/github.com/maliceio/malice-bro \
  && export GOPATH=/go \
  && go version \
  && go get \
  && go build -ldflags "-X main.Version=$(cat VERSION) -X main.BuildTime=$(date -u +%Y%m%d)" -o /bin/bro-scan \
  && rm -rf /go /usr/local/go /usr/lib/go /tmp/* \
  && apk del --purge .build-deps

WORKDIR /malware

ENTRYPOINT ["su-exec","malice","/sbin/tini","--","bro-scan"]
CMD ["--help"]
