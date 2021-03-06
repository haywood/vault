#!/bin/bash -e

# uncomment to get command tracing from bash
if [ -n "$DEBUG" ]; then
  set -x
fi

VAULT_INSTALL="$(dirname $0)/.."
VAULT_LIB="$VAULT_INSTALL/lib"
VAULT_WORK_SPACE="$(mktemp -d -t vault-work-space)"
VAULT_WORK_TREE="$VAULT_WORK_SPACE/work-tree"
VAULT_FILE="$VAULT_WORK_TREE/vault"

# setup work space and cleanup thereof
mkdir -p $VAULT_WORK_SPACE/{content,init,pull,work-tree}
trap "rm -rf $VAULT_WORK_SPACE" EXIT

shopt -s expand_aliases
unalias -a # clear any existing aliases

source $VAULT_LIB/functions.sh
source $VAULT_LIB/prerequisites.sh
source $VAULT_LIB/aliases.sh

CMD="$1"
shift

set_repo

case $CMD in
  init)
    # Initialize a brand new vault repository at the specified remote.
    # Also checks out a local unencrypted version when done.
    REMOTE="$1"
    true ${REMOTE:?Remote is required}
    init
    ;;
  clone)
    # Clone a vault repo from a server and checkout an unencrypted local version.
    REMOTE=$1
    CLONE_DIR=$2
    true ${REMOTE:?Remote is required}
    clone
    ;;
  checkout)
    # Checkout unencrypted data locally. Does not fetch data from the server.
    load_config
    checkout
    ;;
  push)
    # Encrypt committed changes, push them to the server, and wipe out local
    # unencrypted data.
    load_config
    push # push the shadow repo to the remote
    clean
    ;;
  fetch)
    # Fetch the latest data from the server, decrypting and fetching into
    # the local, unencrypted repo as well.
    load_config
    fetch
    ;;
  pull)
    # Fetch data from the remote, decrypt it, and use git pull to
    # merge it with the local copy.
    load_config
    pull
    ;;
  *)
    usage
    ;;
esac
