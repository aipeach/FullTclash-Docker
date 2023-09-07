FROM golang:1.20.7-alpine AS build-core

WORKDIR /app/fulltclash-origin
RUN apk add --no-cache git && \
    git clone https://github.com/AirportR/FullTCore.git /app/fulltclash-origin && \
    go build -ldflags="-s -w" fulltclash.go

WORKDIR /app/fulltclash-meta
RUN git clone -b meta https://github.com/AirportR/FullTCore.git /app/fulltclash-meta && \
    go build -tags with_gvisor -ldflags="-s -w" fulltclash.go && \
    mkdir /app/FullTCore-file && \
    cp /app/fulltclash-origin/fulltclash /app/FullTCore-file/fulltclash-origin && \
    cp /app/fulltclash-meta/fulltclash /app/FullTCore-file/fulltclash-meta


FROM python:3.9.18-alpine3.18 AS compile-image

RUN apk add --no-cache \
    gcc g++ make libffi-dev libxml2-dev libxslt-dev openssl-dev jpeg-dev musl-dev build-base rust cargo ca-certificates

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
ADD https://raw.githubusercontent.com/AirportR/FullTclash/dev/requirements.txt .
RUN pip3 install -r requirements.txt && \
    pip3 install supervisor

FROM python:3.9.18-alpine3.18

COPY *.conf /tmp
WORKDIR /app
RUN apk add --no-cache \
    git tzdata curl jq bash nano && \
    git clone -b dev https://github.com/AirportR/FullTclash.git /app && \
    cp resources/config.yaml.example resources/config.yaml && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    echo "00 6 * * * bash /app/update.sh" >> /var/spool/cron/crontabs/root && \
    mkdir /etc/supervisord.d && \
    mv /tmp/supervisord.conf /etc/supervisord.conf && \
    mv /tmp/fulltclash.conf /etc/supervisord.d/fulltclash.conf && \
    rm -f bin/*

COPY --chmod=755 *.sh .
COPY --from=compile-image /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=compile-image /opt/venv /opt/venv
COPY --from=build-core /app/FullTCore-file/* ./bin/

ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["./docker-entrypoint.sh"]