#!/bin/bash

set -e

ZIP_OUTPUT="package.zip"

usage() {
  echo "Usage: $0 {build|deploy|destroy|arn} [-y]"
  echo "  build         Create layer zip file but don't deploy."
  echo "  deploy [-y]   Deploy; if zip is missing, will build first. With -y, auto-approve for CDK deploy."
  echo "  destroy [-y]  Destroy the layer and delete the zip. With -y, auto-approve for CDK deploy."
  echo "  arn           Output the layer version arn"

}

detect_auto_approve() {
  auto_approve=false
  for arg in "$@"; do
    if [ "$arg" == "-y" ]; then
      auto_approve=true
    fi
  done
  $auto_approve && return 0 || return 1
}

check_dependencies() {
  for dep in docker jq; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      echo "Error: $dep is not installed or not in PATH."
      exit 1
    fi
  done
}

build() {
    docker build --no-cache -t im .
    docker run -itd --rm --name imagemagick im "tail -f /dev/null"
    docker cp imagemagick:/package.zip .
    docker stop imagemagick
}

destroy() {
  if detect_auto_approve "$@"; then
      cdk destroy --require-approval never
    else
      cdk destroy
    fi
}

deploy() {
  auto_approve=false
  while [[ "$1" != "" ]]; do
    case $1 in
      -y )
        auto_approve=true
        ;;
    esac
    shift
  done

  check_and_bootstrap_cdk

  if [ ! -f "$ZIP_OUTPUT" ]; then
    build
  fi
  if detect_auto_approve "$@"; then
    cdk deploy --require-approval never
  else
    cdk deploy
  fi
  arn
}

check_and_bootstrap_cdk() {
  if ! aws cloudformation describe-stacks --stack-name DaImagemagickLambdaLayerStack >/dev/null 2>&1; then
    cdk bootstrap
  fi
}

arn() {
  aws cloudformation describe-stacks --stack-name  DaImagemagickLambdaLayerStack --query 'Stacks[0].Outputs' | jq -r '.[] | select(.ExportName == "layerArn") | .OutputValue'
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

check_dependencies

cmd="$1"
shift

case "$cmd" in
  build)
    build
    ;;
  deploy)
    deploy "$@"
    ;;
  destroy)
    destroy "$@"
    ;;
  arn)
    arn "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac