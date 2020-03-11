bash ../../misc_scripts/gtex_v8_preprocess/extract_columns.sh <(printf 'GENE_ID' | cat $2 -) <(zcat < $1) > $3.temp
cat $3.temp | gzip > $3
rm $3.temp
