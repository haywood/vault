mkdir a b

cd a
vault init file://$REPO

cd ..
vault clone file://$REPO b

cd a
echo foo > bar
git add bar
git commit -m "bar"
vault push
vault checkout

cd ../b
vault pull

cd ..
[ "foo" = $(cat a/bar) ]
[ "foo" = $(cat b/bar) ]
