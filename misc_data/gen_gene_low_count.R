library(dplyr)

dl = readRDS('/scratch/t.cri.yliang/mixqtl-pipeline-results/gtex_v8-preprocess/expression/merge-Whole_Blood.rds')
trc_cutoff = 50
trc_nobs_cutoff = 670

trc = rowSums(dl$df_trc <= trc_cutoff)

df = data.frame(n_low_trc = trc, gene = rownames(dl$df_trc))

df = df %>% mutate(pass_trc_low = n_low_trc >= trc_nobs_cutoff)

write.table(df %>% filter(pass_trc_low) %>% filter(gene != 'ENSG00000223571') %>% select(gene), 'gtex-v8-genes-low-expr_gene_list.txt', row = F, col = F, quo = F, sep = '\t')
# ENSG00000223571 does not have any SNP


