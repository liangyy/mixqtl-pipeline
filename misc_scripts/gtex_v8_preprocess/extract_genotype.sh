# 1: input VCF
# 2: region
# 3: row number of header for output
# 4: output
zcat $1 | head -n $3 | tail -n 1 > $4.temp
tabix $1 $2 >> $4.temp
cat $4.temp | gzip > $4
rm $4.temp
