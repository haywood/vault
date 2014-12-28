# Functions for use by the vault script

function not_implemented {
echo >&2 "The '$CMD' functionality is not yet implemented."
exit 1
}

function usage {
cat >&2 <<EOF
Usage: vault init|clone|push|pull|clean
init <remote>
EOF
exit 1
}

function generate_config {
if [ -f .vault.json ]; then
  echo >&2 "Refusing to generate .vault.json, as it is already present."
  exit 1
fi
cat > .vault.json <<EOF
{
  "remote": "$REMOTE"
}
EOF
}

function generate_gitignore {
cat > .gitignore <<EOF
.vault.json
EOF
}

function generate_seed {
# 256 bytres of random data so that the contents of an empty
# vault repository cannot be guessed easily
cat > .vault.seed <<EOF
$(head -c256 /dev/urandom)
EOF
}

function load_config {
FILE=${1:-.vault.json}
if [ -f $FILE ]; then
  eval "$(cat .vault.json | jq -r '"REMOTE="+.remote+";"')"
  set_remote "$REMOTE"
fi
}

function encrypt {
echo "Encrypting repo in $(pwd) for $REMOTE..."
TMP="$(mktemp -d -t vault-enc)"
VAULT_FILE="$TMP/vault" # file shouldn't exist, as gpg won't want to overwrite it
# TODO read recipients from config
tar -czf - . | $GPG --encrypt --recipient mreed@gilt.com --output $VAULT_FILE
}

function decrypt {
echo "Decrypting repo $REMOTE..."
$GPG -d $VAULT_REPO/vault | tar -x
git status
}

function checkout {
echo "Checking out $REMOTE in $(pwd)..."
decrypt
}

function pull {
echo "Pulling from $REMOTE in $(pwd)..."
pushd $VAULT_REPO
git fetch
git reset --hard origin/master
popd
TMP="$(mktemp -d -t vault-pull)"
pushd $TMP
decrypt
popd
git pull file://$TMP master
}

function add {
true ${VAULT_FILE:?PROGRAMMER ERROR: VAULT_FILE not set}
[ -f "$VAULT_FILE" ]
pushd $VAULT_REPO
mv $VAULT_FILE vault
git add vault
popd
}

function commit {
VAULT_SHA="$($GIT rev-parse HEAD)"
pushd $VAULT_REPO
$GIT commit -m "vault: $VAULT_SHA"
popd
}

function push {
assert_config
pull # make sure we are up compatible with latest from server
encrypt # encrypt our new version of the git database
add # add the vault file to the shadow repo
commit # commit the vault file to the shadow repo
pushd $VAULT_REPO
git push -u origin master
popd
}

function clean {
STATUS=$($GIT status --porcelain --untracked)
if [ -n "$STATUS" ]; then
  cat >&2 <<EOF
Cannot clean when the repo is dirty or has untracked files.

$STATUS

EOF
  exit 1
fi
git clean -fdx
for file in $($GIT ls-files); do
  rm $file
done
rm -rf .git
}

function assert_config {
if [ ! -f .vault.json ]; then
  echo >&2 'Not a vault repository. No .vault.json file found.'
  exit 1
fi
}

function assert_empty {
find . -maxdepth 0 -empty
}

function init_success {
cat <<EOF
Successfully initialized vault repository in $REMOTE.
To use the new repo:

    vault clone $REMOTE

EOF
}

function init {
echo "Initializing vault repo for $REMOTE in $VAULT_REPO..."
git clone $REMOTE $VAULT_REPO
pushd $(mktemp -d -t vault-init)
git init
generate_gitignore
generate_seed
git add -A
$GIT commit -m "initialized vault repository"
encrypt
popd
pushd $VAULT_REPO
assert_empty || git rm -rf '*' # wipe out whatever is already there
add # add the vault file
$GIT commit -m "vault: initialized empty vault repository"
git push
popd
init_success
}

function clone {
if [ -e $VAULT_REPO ]; then
  echo >&2 "Repo already cloned. Skipping..."
else
  git clone $REMOTE $VAULT_REPO
fi
NAME=$(basename $REMOTE .git) # TODO properly parse URL
mkdir -p $NAME
pushd $NAME
assert_empty
generate_config
checkout
popd
}

function set_remote {
REMOTE=$1
true ${REMOTE:?Remote is required}
VAULT_REPO="$VAULT_ROOT/repos/$REMOTE"
}
