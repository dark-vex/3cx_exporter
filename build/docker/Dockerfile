FROM golang:1.19.3 AS builder

LABEL build=3cx-exporter

COPY . /3cx-exporter
WORKDIR /3cx-exporter

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
        -ldflags="-w -s" \
        -o bin/3cx-exporter

FROM alpine:3.16

COPY --from=builder /3cx-exporter/bin/3cx-exporter /usr/bin/3cx-exporter

# Use an unprivileged user.
USER 65535

EXPOSE 9523

ENTRYPOINT ["3cx-exporter"]
