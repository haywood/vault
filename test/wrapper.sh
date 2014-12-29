#!/bin/bash -e

# export all variables
set -a

TEST="$(cd $(dirname $1) && pwd -P)/$(basename $1)"

WORKSPACE="$(mktemp -d -t "vault-test-workspace.XXX")"
CLONE="$WORKSPACE/clone"
REPO="$WORKSPACE/repo"

mkdir -p $REPO $CLONE

cd $REPO && git init --bare

cd $WORKSPACE

/bin/bash -ex "$TEST"
