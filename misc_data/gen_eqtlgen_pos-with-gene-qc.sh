# ARGV:
# 1. size of sub-sample
# 2. gene list

prefix=eqtlgen_pos
genelist=gtex-v8-genes-passed-qc_gene_list.txt  # $2
size=100000

if [ ! -f $prefix.pos-with-gene-qc.txt.gz ];then
  awk 'FNR==NR{a[$1]=1;next}{ if($8 in a) print $0}' $genelist <(zcat /gpfs/data/im-lab/nas40t2/yanyul/eQTLGen/cis-eQTL_significant_20181017_with_GTExV8ID.txt.gz) | gzip > $prefix.pos-with-gene-qc.txt.gz
fi

nrow=`zcat $prefix.pos-with-gene-qc.txt.gz | wc -l` 

Rscript subsample_idx.R --number_total $nrow --number_sub $size --output $prefix.idx.subsample$size-with-gene-qc.txt

awk 'FNR==NR{a[$1]=1;next}{ if(FNR in a) print $0}' $prefix.idx.subsample$size-with-gene-qc.txt <(zcat $prefix.pos-with-gene-qc.txt.gz) | gzip > $prefix.subsample$size-with-gene-qc.txt.gz

