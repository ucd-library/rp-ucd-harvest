#! /bin/bash

echo "Harvesting $1"
PARAM=userId=$1
echo "$PARAM"


# http --verbose  --ignore-stdin www.google.com
harvest login


ucdid fetch --format=ttl --search="userId=jrmerz" profiles


harvest -v -v user --no-remove --search="${PARAM}"