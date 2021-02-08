#! /bin/bash

# manually setting this... for now :(
TAG_NAME=1.0.0

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

repo=$(basename $ROOT_DIR)

echo "Submitting build to Google Cloud..."
gcloud builds submit \
  --config ./cloudbuild.yaml \
  --substitutions=REPO_NAME=${repo},TAG_NAME=$TAG_NAME,BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD),SHORT_SHA=$(git log -1 --pretty=%h) \
  $ROOT_DIR
