cd $CLONE

vault init file://$REPO

[ -z "$(git status --porcelain --untracked)" ]

cd $REPO

[ 1 = $(git log --oneline | wc -l) ]
