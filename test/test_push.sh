cd $CLONE
vault init file://$REPO
echo foo > bar
git add bar
git commit -m "bar"
vault push
