FROM golang:1.20-bullseye as builder
WORKDIR $GOPATH/src/go.k6.io/k6
COPY . .
RUN CGO_ENABLED=0 go install -a -trimpath -ldflags "-s -w -X go.k6.io/k6/lib/consts.VersionDetails=$(date -u +"%FT%T%z")/$(git describe --tags --always --long --dirty)"

FROM debian:bullseye
USER root
RUN adduser --disabled-password --gecos "" appuser
RUN apt-get update
RUN apt-get install -y sudo
RUN echo "appuser ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/appuser && chmod 0440 /etc/sudoers.d/appuser
COPY --from=builder /go/bin/k6 /usr/bin/k6

WORKDIR /home/k6