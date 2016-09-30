#!/bin/bash
#
# https://github.com/jasonmcintosh/rabbitmq-zabbix
#
cd "$(dirname "$0")"
. .rab.auth
./api.py --username=$USERNAME --password=$PASSWORD --protocol=$RABBITMQ_PROTOCOL --hostname=$RABBITMQ_HOSTNAME --port=$RABBITMQ_PORT --check=list_nodes --filter="$FILTER" --conf=$CONF --senderhostname=$SENDERHOSTNAME
