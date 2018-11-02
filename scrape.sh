# grab image from public site
# usage: sh scrape.sh Aesthetics_of_Space

mkdir -p images/$1
cat html/$1 | \
  (export file=`perl -ne 'print "$1\n" if /sites\/default\/files\/styles\/large\/public\/upload\/patterns\/(.*?)\?/'`
  echo "$file"
  curl -s "https://groupworksdeck.org/sites/default/files/styles/large/public/upload/patterns/$file" > images/$1/$file)
