FROM python:3.11.6-alpine3.18 AS compile-image

RUN apk add --no-cache \
    gcc g++ make libffi-dev libstdc++ gcompat libgcc build-base py3-pybind11-dev abseil-cpp-dev re2-dev

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

FROM python:3.11.6-alpine3.18

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