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
    gcc g++ make libffi-dev

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
ADD https://raw.githubusercontent.com/AirportR/FullTclash/dev/requirements.txt
RUN pip3 install -r requirements.txt

FROM alpine:latest

WORKDIR /app
RUN apk add --no-cache \
    git tzdata && \
    git clone -b dev https://github.com/AirportR/FullTclash.git /app && \
    cp resources/config.yaml.example resources/config.yaml && \
    rm -f bin/*

COPY --from=compile-image /opt/venv /opt/venv
COPY --from=build-core /app/FullTCore-file/* ./bin/

ENV TZ Asia/Shanghai
ENV PATH="/opt/venv/bin:$PATH"

CMD ["main.py"]
ENTRYPOINT ["python3"]