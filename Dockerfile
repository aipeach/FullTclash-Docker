FROM python:3.11.6-alpine3.18 AS compile-image

RUN apk add --no-cache \
    gcc g++ make libffi-dev libstdc++ gcompat libgcc build-base py3-pybind11-dev abseil-cpp-dev re2-dev

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

FROM python:3.11.6-alpine3.18

WORKDIR /app
COPY fulltcore.sh .
RUN apk add --no-cache \
    git tzdata && \
    git clone -b backend --single-branch --depth=1 https://github.com/AirportR/FullTclash.git /app && \
    cp resources/config.yaml.example resources/config.yaml && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    chmod +x /app/fulltcore.sh && \
    /app/fulltcore.sh && \
    cp /app/bin/fulltclash-meta /app/bin/fulltclash-linux-amd64 && \
    apk del tzdata

COPY --from=compile-image /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["python3", "main.py"]