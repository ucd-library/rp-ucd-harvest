#! /bin/bash

TAG_NAME=1.0.0

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

repo=$(basename $ROOT_DIR)

export DOCKER_BUILDKIT=1
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t ucdlib/${repo}:$TAG_NAME \
  $ROOT_DIR
