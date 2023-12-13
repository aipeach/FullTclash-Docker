FROM gogost/gost:latest AS gost-image

FROM aipeach/fulltclash:ws

ENV TZ=Asia/Shanghai
ENV local=192.168.123.2/24
ENV remote=192.168.123.1/32
ENV through=1.2.3.4:8421
ENV passphrase=userpass
ENV bind=0.0.0.0:8765
ENV token=fulltclash
ENV branch=origin
ENV core=4

COPY docker-entrypoint.sh /opt/
COPY --from=gost-image /bin/gost /bin/gost

RUN apk add --no-cache \
    iptables bash tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    mkdir /etc/gost && \
    chmod +x /opt/docker-entrypoint.sh && \
    chmod +x /bin/gost

ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/opt/docker-entrypoint.sh"]