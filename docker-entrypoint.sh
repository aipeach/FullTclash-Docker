#!/bin/bash

if [[ ! -f /etc/gost/config.yml ]]; then
cat > /etc/gost/config.yml <<EOF
services:
- name: tun
  addr: :0
  handler:
    type: tun
    metadata:
      keepAlive: true
      ttl: 10s
  listener:
    type: tun
    metadata:
      net: ${local}
      route: ${remote}
  forwarder:
    nodes:
    - name: target-0
      addr: ${through}
EOF
fi

if [[ ! -f /app/resources/config.yaml ]]; then
cat > /app/resources/config.yaml <<EOF
clash:
 path: './bin/fulltclash-${branch}'
 core: ${core}
 startup: 1124
 branch: ${branch}
EOF
fi

nohup gost -C /etc/gost/config.yml 2>&1 &

python3 /app/main.py -t ${token} -b ${bind}