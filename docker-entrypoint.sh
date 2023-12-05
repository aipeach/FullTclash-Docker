#!/bin/bash

config(){
cat > /app/resources/config.yaml <<EOF
clash:
 path: './bin/fulltclash-${branch}'
 core: ${core}
 startup: 11124
 branch: ${branch}
EOF
}

if [[ ! -f /app/resources/config.yaml ]]; then
    config
fi

python3 /app/main.py -t ${token} -b ${bind}