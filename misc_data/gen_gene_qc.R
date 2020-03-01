library(dplyr)

dl = readRDS('/scratch/t.cri.yliang/mixqtl-pipeline-results/gtex_v8-preprocess/expression/merge-Whole_Blood.rds')
trc_cutoff = 100
asc_cutoff = 50
trc_nobs_cutoff = 500
asc_nobs_cutoff = 15

trc = rowSums(dl$df_trc >= trc_cutoff)
asc = rowSums(dl$df_ase1 >= asc_cutoff & dl$df_ase2 >= asc_cutoff)
df = data.frame(n_good_trc = trc, n_good_asc = asc, gene = rownames(dl$df_trc))
# df %>% ggplot() + th + geom_point(aes(x = n_good_trc, y = n_good_asc), alpha = .2) + geom_hline(yintercept = asc_nobs_cutoff, linetype = 2, color = 'red') + geom_vline(xintercept = trc_nobs_cutoff, linetype = 2, color = 'red')

df = df %>% mutate(pass_trc_qc = n_good_trc >= trc_nobs_cutoff, pass_asc_qc = n_good_asc >= asc_nobs_cutoff)

write.table(df %>% filter(pass_asc_qc, pass_trc_qc) %>% select(-pass_asc_qc, -pass_trc_qc), 'gtex-v8-genes-passed-qc.txt', row = F, col = T, quo = F, sep = '\t')
write.table(df %>% filter(pass_asc_qc, pass_trc_qc) %>% select(gene), 'gtex-v8-genes-passed-qc_gene_list.txt', row = F, col = F, quo = F, sep = '\t')

