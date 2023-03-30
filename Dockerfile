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
ENV NODE_VERSION=16.13.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version
COPY --from=builder /go/bin/k6 /usr/bin/k6

WORKDIR /app