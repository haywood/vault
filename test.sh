#!/bin/bash -ex

cd $(dirname $0)
PATH="$(pwd)/bin:$PATH"

VAULT_TEST="$HOME/vault-test"
if [ ! -d $VAULT_TEST  ]; then
  mkdir -p $VAULT_TEST
  cd $VAULT_TEST
  git init --bare
fi

WORKSPACE="$(mktemp -d -t "vault-test-workspace")"
cd $WORKSPACE

vault init file://$VAULT_TEST
vault clone file://$VAULT_TEST
cd vault-test
vault fetch
vault pull
echo 'Hello, World!' > test
git add test
git commit -m "testing"
vault push
[ ! -e test ]
vault checkout
cat test
vault clean
vault checkout
cat test
