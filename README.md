# FullTclash-Docker

> docker镜像可选`dev`或者`alpine`，`dev`是通过`Debian`构建的，
> branch设置内核分支，可选`origin`或者`meta`，
> 其他设置请参考 <https://github.com/AirportR/FullTclash/tree/dev#%E4%B8%BAbot%E8%BF%9B%E8%A1%8C%E7%9B%B8%E5%85%B3%E9%85%8D%E7%BD%AE>

快速启动

```bash
docker run -idt \
   --name fulltclash \
   -e admin=12345678 \
   -e api_id=123456 \
   -e api_hash=ABCDEFG \
   -e bot_token=123456:ABCDEFG \
   -e branch=origin \
   -e core=4 \
   -e startup=1124 \
   -e speedthread=4 \
   -e nospeed=true \
   -e s5_proxy=127.0.0.1:7890 \
   -e http_proxy=127.0.0.1:7890 \
   --network=host \
   --restart always \
   aipeach/fulltclash:alpine
```

挂载配置文件启动，新建配置目录`mkdir /etc/fulltclash`

```bash
docker run -itd \
   --name=fulltclash \
   --network=host \
   --restart=always \
   -v /etc/fulltclash/config.yaml:/app/resources/config.yaml \
   aipeach/fulltclash:alpine
```
