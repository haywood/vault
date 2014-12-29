#!/bin/bash -e

# export all variables
set -a

PATH="$TEST_DIR/../bin:$PATH" # add vault to the path

WORKSPACE="$(mktemp -d -t "vault-test-workspace")"
CLONE="$WORKSPACE/clone"
REPO="$WORKSPACE/repo"

mkdir -p $REPO $CLONE

cd $REPO && git init --bare

cd $WORKSPACE

/bin/bash -e "$@"
