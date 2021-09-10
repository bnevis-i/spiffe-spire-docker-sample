# Build

ARG BUILDER_BASE=golang:1.16-alpine
FROM ${BUILDER_BASE} AS builder

WORKDIR /app

COPY go.mod .
COPY *.go .

RUN go mod download
RUN go mod tidy

ENV CGO_ENABLED=0
ENV GO111MODULE=on

RUN go build -o server .

# Run

FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y --no-install-recommends dumb-init && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY spire-agent /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin/

COPY --from=builder /app/server /usr/local/bin/

EXPOSE 443

ENTRYPOINT [ "/usr/bin/dumb-init" ]
CMD [ "--verbose", "docker-entrypoint.sh" ]
