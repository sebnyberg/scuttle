FROM golang:buster AS build

ARG VERSION="local"
COPY . /app
WORKDIR /app
RUN go get -d
RUN go test -test.timeout 30s 
RUN CGO_ENABLED=0 go build -o scuttle -ldflags="-X 'main.Version=${VERSION}'"

FROM ubuntu:18.04

RUN apt-get update -y \
  && apt-get -y install --no-install-recommends \
  curl bash vim htop ca-certificates \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/ \
  && curl -sSL -o /tini https://github.com/krallin/tini/releases/download/v0.19.0/tini \
  && chmod +x /tini

COPY --from=build /app/scuttle /usr/local/bin/scuttle

ENTRYPOINT ["/tini", "--"]
