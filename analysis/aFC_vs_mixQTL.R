df_mix = read.table('~/Desktop/mixqtl-pipeline-results/postprocess-mixqtl/Whole_Blood-x-result-mixqtl-IN-cleaned-Whole_Blood.v8.egenes.txt.gz', header = T)
df_afc = read.delim2('~/Downloads/GTEx_Analysis_v8_eQTL/Whole_Blood.v8.egenes.txt.gz', header = T)
df_afc$log2_aFC = as.numeric(df_afc$log2_aFC)
df_afc$pval_nominal = as.numeric(df_afc$pval_nominal)
df_afc$log2_aFC_lower = as.numeric(df_afc$log2_aFC_lower)
df_afc$log2_aFC_upper = as.numeric(df_afc$log2_aFC_upper)
df_afc$slope = as.numeric(df_afc$slope)
head(df_afc)
library(dplyr)
library(ggplot2)
source('../code/rlib_analysis.R')
merge = inner_join(df_mix %>% select(bhat.trc, bhat.asc, bhat.meta, se.meta, pval.meta, gene, variant_id), df_afc %>% mutate(gene = trim_dot(gene_id)), by = c('gene', 'variant_id'))

plist = list()
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = bhat.meta / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC_lower, y = bhat.meta / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC_upper, y = bhat.meta / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
ggsave('../output/aFC_vs_mixQTL.png', plist[[1]] + plist[[2]] + plist[[3]], width = 10, height = 3)

plist = list()
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC_lower, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC_upper, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
ggsave('../output/aFC_vs_trcQTL.png', plist[[1]] + plist[[2]] + plist[[3]], width = 10, height = 3)

plist = list()
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = bhat.asc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC_lower, y = bhat.asc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
plist[[length(plist) + 1]] = merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC_upper, y = bhat.asc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
ggsave('../output/aFC_vs_ascQTL.png', plist[[1]] + plist[[2]] + plist[[3]], width = 10, height = 3)

merge %>% ggplot() + geom_point(aes(x = log2_aFC, y = slope), alpha = .2) + geom_abline(slope = 1, intercept = 0, color = 'red')
plot(-log(merge$pval.meta), -log(merge$pval_nominal))
