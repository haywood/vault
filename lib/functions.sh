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
.vault
.vault.json
EOF
}

function load_config {
FILE=${1:-.vault.json}
if [ -f $FILE ]; then
  eval "$(cat .vault.json | jq -r '"REMOTE=\""+.remote+"\";"')"
else
  echo >&2 'Not a vault repository. No .vault.json file found.'
  exit 1
fi
}

function encrypt {
echo "Encrypting repo in $(pwd) for $REMOTE..."
if [ -e $VAULT_FILE ]; then
  # file shouldn't exist, as gpg won't want to overwrite it
  rm $VAULT_FILE
fi
# TODO read recipients from config
tar -czf - .git | $GPG --encrypt --recipient mreed@gilt.com --output $VAULT_FILE
}

function decrypt {
echo "Decrypting repo $REMOTE..."
vault checkout HEAD vault
pushd $VAULT_WORK_SPACE/content
  $GPG -d $VAULT_FILE | tar -x
popd
}

function checkout {
if [ ! -e .git ]; then
  # when vault clean is run, we remove .git
  # also when initting, we may not have a .git
  git init
fi
echo "Checking out $REMOTE in $(pwd)..."
decrypt
git pull file://$VAULT_WORK_SPACE/content master
}

function pull {
echo "Pulling from $REMOTE in $(pwd)..."
fetch
git pull file://$VAULT_WORK_SPACE/content master
}

function fetch {
vault fetch # fetch from the server
# we are throwing away anything already here
# this is OK, as the vault is just as staging
# area between the server and the local copy
vault reset FETCH_HEAD # reset the vault to the server
decrypt # decrypt the vault
git fetch file://$VAULT_WORK_SPACE/content # fetch from the decrypted repo
}

function add {
true ${VAULT_FILE:?PROGRAMMER ERROR: VAULT_FILE not set}
[ -f "$VAULT_FILE" ]
vault add $VAULT_FILE
}

function commit {
VAULT_SHA="$($GIT rev-parse HEAD)"
vault commit -m "vault: $VAULT_SHA"
}

function push {
pull # make sure we are up compatible with latest from server
encrypt # encrypt our new version of the git database
add # add the vault file to the shadow repo
commit # commit the vault file to the shadow repo
vault push -u origin master
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
git clean -fd
for file in $($GIT ls-files); do
  rm $file
done
rm -rf .git
}

function assert_empty {
DIR=${1:-.}
find $DIR -maxdepth 0 -empty
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
git clone --bare $REMOTE $VAULT_REPO
pushd $VAULT_WORK_SPACE/init
  git init
  generate_gitignore
  git add -A
  git commit -m "initialized vault repository"
  encrypt
popd
assert_empty $VAULT_REPO
add # add the vault file
vault commit -m "vault: initialized empty vault repository"
vault push -u origin master
generate_config
checkout
init_success
}

function clone {
true ${CLONE_DIR:=$(basename $REMOTE .git)} # TODO properly parse URL
mkdir -p $CLONE_DIR
assert_empty $CLONE_DIR
pushd $CLONE_DIR
  set_repo
  git clone --bare $REMOTE $VAULT_REPO
  generate_config
  checkout
popd
}

function set_repo {
REPO="$(pwd)"
VAULT_REPO="$REPO/.vault"
mkdir -p "$VAULT_REPO"
}

function vault {
  GIT_WORK_TREE="$VAULT_WORK_TREE" GIT_DIR="$VAULT_REPO" git "$@"
}
