FROM aipeach/fulltclash:ameta AS compile-image


FROM python:3.9.18-alpine3.18

ENV bind=0.0.0.0:8765
ENV token=fulltclash
ENV branch=origin
ENV core=4

WORKDIR /app
COPY *.sh /opt/
RUN apk add --no-cache \
    git tzdata bash && \
    git clone -b backend --single-branch --depth=1 https://github.com/AirportR/FullTclash.git /app && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    chmod +x /opt/*.sh && \
    /opt/fulltcore.sh && \
    apk del tzdata

COPY --from=compile-image /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/opt/docker-entrypoint.sh"]