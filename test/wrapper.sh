#!/bin/bash -e

# export all variables
set -a

PATH="$(cd $(dirname $0) && pwd -P)/../bin:$PATH" # add vault to the path
TEST="$(cd $(dirname $1) && pwd -P)/$(basename $1)"

WORKSPACE="$(mktemp -d -t "vault-test-workspace")"
CLONE="$WORKSPACE/clone"
REPO="$WORKSPACE/repo"

mkdir -p $REPO $CLONE

cd $REPO && git init --bare

cd $WORKSPACE

/bin/bash -ex "$TEST"
