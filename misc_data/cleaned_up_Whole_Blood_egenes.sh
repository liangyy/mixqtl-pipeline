# something
zcat Whole_Blood.v8.egenes.txt.gz |tail -n +2|awk '{split($1,a,"."); print a[1]"\t"$0}' | gzip > cleaned-Whole_Blood.v8.egenes.txt.gz
