mkdir one two

cd one
vault init file://$REPO

cd ..
vault clone file://$REPO two

cd one
echo foo > bar
git add bar
git commit -m "bar"
vault push
vault checkout

cd ../two
vault pull

cd ..
diff one/bar two/bar
