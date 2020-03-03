# to generate a subset of genes for subsampling analysis

library(data.table) 
options(datatable.fread.datatable = F)
library(dplyr)

set.seed(2020)
n = 1000

# source('../../../scripts/rlib_minimal_test.R')
# R function in the loaded script
trim_dot = function(str) {
  unlist(lapply(strsplit(as.character(str), '\\.'), function(x) { x[1] }))
}
# END

# to select genes with at least one high confident causal signal, we load DAPG runs on whole blood (based on normalized expression)
dapg = fread('zcat /gpfs/data/im-lab/nas40t2/abarbeira/projects/gtex_v8/dapg/eqtl/parsed_dapg/Whole_Blood.clusters.txt.gz', header = T, stringsAsFactors = F)
dapg = dapg %>% mutate(gene = trim_dot(gene)) %>% filter(pip > 0.95) 
dapg_genes = unique(dapg$gene)
message(length(dapg_genes))
f = read.table('gtex-v8-genes-passed-qc_gene_list.txt', header = F, stringsAsFactors = F)
f = f$V1[f$V1 %in% dapg_genes]
message(length(f))
f = f[sample(1 : length(f), size = n, replace = F)]
write.table(data.frame(x = f), 'gene_list_whole_blood_for_subsampling_with_qc.txt', col = F, row = F, quo = F) 

