FROM python:3.9.18-slim-bookworm AS compile-image

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    gcc g++ make ca-certificates

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
ADD https://raw.githubusercontent.com/AirportR/FullTclash/dev/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt && \
    pip3 install --no-cache-dir supervisor

FROM python:3.9.18-slim-bookworm

WORKDIR /app

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git tzdata curl wget jq bash nano cron && \
    git clone -b dev --single-branch --depth=1 https://github.com/AirportR/FullTclash.git /app && \
    cp resources/config.yaml.example resources/config.yaml && \
    rm -f /etc/localtime && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    mkdir /etc/supervisord.d && \
    mv /app/docker/supervisord.conf /etc/supervisord.conf && \
    mv /app/docker/fulltclash.conf /etc/supervisord.d/fulltclash.conf && \
    chmod +x /app/docker/fulltcore.sh && \
    /app/docker/fulltcore.sh && \
    cp /app/docker/crontab /etc/cron.d/crontab && \
    chmod 0644 /etc/cron.d/crontab && \
    /usr/bin/crontab /etc/cron.d/crontab && \
    chmod +x /app/docker/update.sh && \
    chmod +x /app/docker/docker-entrypoint.sh && \
    rm -rf /var/lib/apt/lists/*

COPY --from=compile-image /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=compile-image /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/app/docker/docker-entrypoint.sh"]
