#!/bin/bash

supervisord -c /etc/supervisord.conf

crond -f > /dev/null 2>&1