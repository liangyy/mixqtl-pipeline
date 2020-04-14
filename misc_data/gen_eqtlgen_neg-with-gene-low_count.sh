# ARGV:
# 1. size of sub-sample
# 2. gene list

prefix=eqtlgen_neg_low_count
genelist=gtex-v8-genes-low-expr_gene_list.txt  # $2
size=100000

if [ ! -f $prefix.pval_gt_0.5.txt.gz ]; then
  zcat /gpfs/data/im-lab/nas40t2/yanyul/eQTLGen/cis-eQTLs_full_20180905_with_GTExV8ID.txt.gz | awk '{split($1,b,"E"); if($1>0.5 && b[2]=="") print $0}' | gzip > $prefix.pval_gt_0.5.txt.gz
fi

if [ ! -f $prefix.pval_gt_0.5-with-gene-low-expr.txt.gz ];then
  awk 'FNR==NR{a[$1]=1;next}{ if($8 in a) print $0}' $genelist <(zcat $prefix.pval_gt_0.5.txt.gz) | gzip > $prefix.pval_gt_0.5-with-gene-low-expr.txt.gz
fi

nrow=`zcat $prefix.pval_gt_0.5-with-gene-low-expr.txt.gz | wc -l`

Rscript subsample_idx.R --number_total $nrow --number_sub $size --output $prefix.idx.subsample$size-with-gene-low-expr.txt

awk 'FNR==NR{a[$1]=1;next}{ if(FNR in a) print $0}' $prefix.idx.subsample$size-with-gene-low-expr.txt <(zcat $prefix.pval_gt_0.5-with-gene-low-expr.txt.gz) | gzip > $prefix.subsample$size-with-gene-low-expr.txt.gz

