#!/bin/bash

PUSHGATEWAY_SERVER=http://47.242.0.105:9091
NODE_NAME=`hostname`



avalanchego_metric=`curl -s -X POST 127.0.0.1:9650/ext/metrics --data-raw ''`
cat << EOF | curl -s --data-binary @- $PUSHGATEWAY_SERVER/metrics/job/avax-node/instance/$NODE_NAME
  $avalanchego_metric
EOF

STATUS_HEALTHY=$(curl --silent  -X POST --data '{
       "jsonrpc":"2.0",
       "id"     :1,
       "method" :"health.getLiveness"
   }' -H 'content-type:application/json;' 127.0.0.1:9650/ext/health | jq '.result.healthy')

if [[ "$STATUS_HEALTHY" == "true" ]]; then
    echo 'Is true'
    STATUS_HEALTHY=1
else
    echo 'Is false'
    STATUS_HEALTHY=0
fi

cat << EOF | curl -s --data-binary @- $PUSHGATEWAY_SERVER/metrics/job/avax-node/instance/$NODE_NAME
  avalanchego_health_status $STATUS_HEALTHY
EOF

node_exporter_metric=`curl -s  http://127.0.0.1:9100/metrics`
cat << EOF | curl -s --data-binary @- $PUSHGATEWAY_SERVER/metrics/job/avax-node/instance/$NODE_NAME
  $node_exporter_metric
EOF

# curl -s http://127.0.0.1:9100/metrics | curl --data-binary @- $PUSHGATEWAY_SERVER/metrics/job/avax-node/instance/$NODE_NAME


echo ">>> : $PUSHGATEWAY_SERVER/metrics/job/avax-node/instance/$NODE_NAME"


z=$(ps aux)
while read -r z
do
   var=$var$(awk '{print "cpu_usage{process=\""$11"\", pid=\""$2"\"}", $3z}');
done <<< "$z"

cat << EOF | curl -s --data-binary @- $PUSHGATEWAY_SERVER/metrics/job/avax-node/instance/$NODE_NAME
  $var
EOF
