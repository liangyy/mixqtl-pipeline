gtexv8signif=/gpfs/data/gtex-group/v8/59349/gtex/exchange/GTEx_phs000424/exchange/analysis_releases/GTEx_Analysis_2017-06-05_v8/eqtl/GTEx_Analysis_v8_eQTL/Whole_Blood.v8.signif_variant_gene_pairs.txt.gz
prefix=gtexv8_pos
genelist=gtex-v8-genes-low-expr_gene_list.txt  

if [ ! -f $prefix.pos-with-low_count_genes.txt.gz ];then
  awk 'FNR==NR{a[$1]=1;next}{split($2,b,"."); if(b[1] in a) print $0"\t"b[1]}' $genelist <(zcat $gtexv8signif) | gzip > $prefix.pos-with-low_count_genes.txt.gz
fi


