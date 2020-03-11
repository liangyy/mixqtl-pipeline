# ARGV:
# 1. [target file] in GZ
# 2. column number of gene in [target file]
# 3. column number of variant in [target file]
# 4. [from file] in GZ
# 5. column number of gene in [from file]
# 6. column number of variant in [from file]
# 7. output file name

target=$1
targetgene=$2
targetvar=$3
fromm=$4
frommgene=$5
frommvar=$6
output=$7

zcat $fromm | head -n 1 > $output.temp

if [[ $targetgene != "-1" && $frommgene != "-1" ]]
then
  awk -v TGENE=$targetgene -v TVAR=$targetvar -v FGENE=$frommgene -v FVAR=$frommvar 'FNR==NR{a[$(TGENE)"-"$(TVAR)]=1;next}{split($(FGENE),b,"."); if(b[1]"-"$(FVAR) in a) print $0}' <(zcat $target) <(zcat $fromm) >> $output.temp
else
  awk -v TVAR=$targetvar -v FVAR=$frommvar 'FNR==NR{a[$(TVAR)]=1;next}{if($(FVAR) in a) print $0}' <(zcat $target) <(zcat $fromm) >> $output.temp
fi
cat $output.temp | gzip > $output
rm $output.temp
