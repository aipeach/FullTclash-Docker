FROM golang:alpine3.18 AS origin

WORKDIR /app
RUN apk add --no-cache git && \
    git clone https://github.com/AirportR/FullTCore.git /app && \
    go build -ldflags="-s -w" fulltclash.go

FROM golang:1.20.7-alpine AS meta

WORKDIR /app
RUN apk add --no-cache git && \
    git clone -b meta https://github.com/AirportR/FullTCore.git /app && \
    go build -tags with_gvisor -ldflags="-s -w" fulltclash.go


FROM python:alpine3.18

WORKDIR /app

RUN apk add --no-cache \
    git gcc g++ make libffi-dev tzdata && \
    git clone -b dev https://github.com/AirportR/FullTclash.git /app && \
    pip3 install --no-cache-dir -r requirements.txt && \
    cp resources/config.yaml.example resources/config.yaml && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del gcc g++ make libffi-dev tzdata && \
    rm -f rm -f bin/*

COPY --from=origin /app/fulltclash ./bin/fulltclash-origin
COPY --from=meta /app/fulltclash ./bin/fulltclash-meta

CMD ["main.py"]
ENTRYPOINT ["python3"]
