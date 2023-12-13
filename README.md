# FullTclash-Docker

> 这是一个实验性的FullTclash纯后端➕Gost组网方式，解决在无公网IP的Linux主机上一键部署后端服务
> 该文档不是教程，本人不保证任何人都能完美运行

## 1.主端安装Gost

> 首先在主端上安装Gost

### 1.1安装

```bash
# 安装最新版本 [https://github.com/go-gost/gost/releases](https://github.com/go-gost/gost/releases)
bash <(curl -fsSL https://github.com/go-gost/gost/raw/master/install.sh) --install
```

### 1.2运行

> 新建gost目录`mkdir /etc/gost`，配置文件参考目录下的`gost.yml`

```bash
gost -C /etc/gost/gost.yml
```

## 2.在后端上启动Docker容器

### 启动容器

```bash
docker run -idt \
    --name fulltclash-gost \
    -e core=4 \
    -e branch=origin \
    -e token=fulltclash \
    -e local=192.168.123.2/24 \
    -e remote=192.168.123.1/32 \
    -e through=1.2.3.4:8421 \
    -e passphrase=userpass1 \
    --cap-add NET_ADMIN \
    --device=/dev/net/tun:/dev/net/tun \
    aipeach/fulltclash:gost
```

### 测试主后端通讯

在主端机器上ping后端的内网IP

```bash
ping 192.168.123.2
```

参数说明

```bash
core 核心数，数量越多测试速度越快，但代价是内存会大量占用
branch clash内核上游分支，仅有两个有效值: [origin, meta]
token Websocket通信Token
local 后端内网地址
remote 主端内网地址
through 主端公网IP和端口
passphrase 主端设置的密码
```

```bash
# 更新镜像
docker pull aipeach/fulltclash:gost
# 删除容器
docker rm -f fulltclash-gost
```

> 如果你还不知道怎么做，主端可以直接使用仓库默认的配置启动，后端修改`token`、`through`这两个参数启动容器，然后主端用后端内网IP加token对接后端
>
> 详细设置请查阅 <https://gost.run/blog/2022/tun/>
