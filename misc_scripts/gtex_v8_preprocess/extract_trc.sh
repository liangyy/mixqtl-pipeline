bash ../../scripts/extract_columns.sh <(printf 'Name\nDescription' | cat $2 -) <(zcat < $1 | tail -n +3) > $3.temp
cat $3.temp | gzip > $3
rm $3.temp
