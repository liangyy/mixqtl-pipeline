# ARGV
# $1: gene list
# $2: prefix of gene file
# $3: suffix of gene file (.GZ)
# $4: output filename TXT.GZ

genelist=$1
prefix=$2
suffix=$3
output=$4

gh=`cat $genelist|head -n 1`
genefileh=$prefix$gh$suffix
header=`zcat $genefileh | head -n 1 | tr '\t' ','`
header=$header",gene,nvar"
echo $header | tr "," "\t" > $output.temp

for g in `cat $genelist`;
do
  genefile=$prefix$g$suffix
  nrow=`zcat $genefile | tail -n +2 | wc -l `
  zcat $genefile | tail -n +2 | awk -v NROW=$nrow -v GENE=$g -v OFS="\t" '{print $0,GENE,NROW}' >> $output.temp
done

cat $output.temp | gzip > $output
rm $output.temp


