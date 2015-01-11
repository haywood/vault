mkdir a b

cd a
vault init file://$REPO

cd ..
vault clone file://$REPO b

cd a
echo foo > bar
git add bar
git commit -m "foo"
vault push
vault checkout

cd ../b
echo baz > bar
git add bar
git commit -m "baz"
! vault push # fails because of conflict

git rebase origin/master # begin resolution
echo baz > bar # overwrite bar
git add bar # mark bar resolved
git rebase --continue # complete resolution
vault push # push the resolved change
vault checkout

# since b has changes that a does not, we should be different
cd ..
[ "foo" = $(cat a/bar) ]
[ "baz" = $(cat b/bar) ]

# update a with the changes from b
cd a
vault pull

cd ..
[ "baz" = $(cat a/bar) ]
[ "baz" = $(cat b/bar) ]
