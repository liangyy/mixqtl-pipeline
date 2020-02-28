library(data.table) 
options(datatable.fread.datatable = F)
library(dplyr)

set.seed(2019)
n = 1000

source('../../../scripts/rlib_minimal_test.R')

dapg = fread('zcat /gpfs/data/im-lab/nas40t2/abarbeira/projects/gtex_v8/dapg/eqtl/parsed_dapg/Whole_Blood.clusters.txt.gz', header = T, stringsAsFactors = F)
dapg = dapg %>% mutate(gene = trim_dot(gene)) %>% filter(pip > 0.95) 
dapg_genes = unique(dapg$gene)
message(length(dapg_genes))
d = fread(cmd = "ls /home/t.cri.yliang/scratch/mixQTL/Whole_Blood/|grep result-TRC_only.E | sed 's#result-TRC_only.##g'|sed 's#.txt.gz##g'", header = F)
message(head(d))
f = read.table('gene_list_whole_blood.txt', header = F, stringsAsFactors = F)
f = f$V1[f$V1 %in% d$V1 & f$V1 %in% dapg_genes]
f = f[sample(1 : length(f), size = n, replace = F)]
write.table(f, 'gene_list_whole_blood_for_subsampling.txt', col = F, row = F, quo = F) 
