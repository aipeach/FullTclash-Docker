#!/bin/bash

if [[ ! -f /app/resources/config.yaml ]]; then
cat > /app/resources/config.yaml <<EOF
clash:
 path: './bin/fulltclash-${branch}'
 core: ${core}
 startup: 1124
 branch: ${branch}
EOF
fi

python3 /app/main.py -t ${token} -b ${bind}