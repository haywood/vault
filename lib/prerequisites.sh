# Prerequisites for use by the vault script

export GIT="$(which git)"
if [ "$?" != "0" ]; then
  echo >&2 'No git command found. Please install git to use vault.'
  exit 1
fi

export GPG="$(which gpg)"
if [ "$?" != "0" ]; then
  echo >&2 'No gpg command found. Please install gpg to use vault.'
  exit 1
fi
