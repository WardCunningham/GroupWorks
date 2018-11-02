# update limited distribution site
# usage: sh sync.sh

rsync -avz ~/.wiki/group.localhost/pages/ asia:.wiki/tree.tries.fed.wiki/pages/
rsync -avz ~/.wiki/group.localhost/assets/ asia:.wiki/tree.tries.fed.wiki/assets/
ssh asia 'cd .wiki/tree.tries.fed.wiki/status; rm -f sitemap.*'