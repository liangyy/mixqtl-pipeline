library(data.table)
options(datatable.fread.datatable = F)
df_mix = read.table('~/Desktop/mixqtl-pipeline-results/postprocess-mixqtl/Whole_Blood-x-result-mixqtl-IN-cleaned-Whole_Blood.v8.egenes.txt.gz', header = T)
df_afc = fread('zcat < ~/Downloads/GTEx_Analysis_v8_eQTL/Whole_Blood.v8.egenes.txt.gz', header = T)
df_afc_impute = fread('~/Downloads/Whole_Blood_imputed.aFC.txt', header = T)
# df_afc$log2_aFC = as.numeric(df_afc$log2_aFC)
# df_afc$pval_nominal = as.numeric(df_afc$pval_nominal)
# df_afc$log2_aFC_lower = as.numeric(df_afc$log2_aFC_lower)
# df_afc$log2_aFC_upper = as.numeric(df_afc$log2_aFC_upper)
# df_afc$slope = as.numeric(df_afc$slope)
afc_merge = inner_join(df_afc, df_afc_impute, by = c('gene_id' = 'pid', 'variant_id' = 'sid'))
plot(afc_merge$log2_aFC.x, afc_merge$log2_aFC.y)
head(df_afc)
library(dplyr)
library(ggplot2)
library(patchwork)
source('../code/rlib_analysis.R')
merge = inner_join(df_mix %>% select(bhat.trc, bhat.asc, bhat.meta, se.meta, pval.meta, gene, variant_id), df_afc %>% mutate(gene = trim_dot(gene_id)), by = c('gene', 'variant_id'))
merge = inner_join(merge, df_afc_impute %>% select(pid, sid, log2_aFC, log2_aFC_lower, log2_aFC_upper) %>% mutate(gene = trim_dot(pid)), by = c('gene', 'variant_id' = 'sid'), suffix = c('', '_imputed'))
plot(merge$log2_aFC, merge$log2_aFC_imputed)


high_quality = function(m, l, u) {
  (u -  l) < 1 & l != -6.643856 & u != 6.643856
}

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
plist[[length(plist) + 1]] = merge %>% mutate(high_quality = high_quality(log2_aFC, log2_aFC_lower, log2_aFC_upper)) %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red') # + facet_wrap(~high_quality, labeller = label_both) 
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

merge %>% mutate(high_quality = high_quality(log2_aFC, log2_aFC_lower, log2_aFC_upper)) %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red') + facet_wrap(~high_quality, labeller = label_both) 

p1 = merge %>% mutate(high_quality = high_quality(log2_aFC, log2_aFC_lower, log2_aFC_upper)) %>% ggplot() + 
  geom_point(aes(x = log2_aFC_imputed, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red') # + facet_wrap(~high_quality, labeller = label_both) 
p2 = merge %>% mutate(high_quality = high_quality(log2_aFC, log2_aFC_lower, log2_aFC_upper)) %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
p3 = merge %>% mutate(high_quality = high_quality(log2_aFC, log2_aFC_lower, log2_aFC_upper)) %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = log2_aFC_imputed), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red')
p1 + p2 + p3

# gene_annot = read.table('https://bitbucket.org/yanyul/rotation-at-imlab/raw/7c966369cf9ac1f2563409b09625a2b3cf2d592e/data/annotations_gencode_v26.tsv', header = T)
# merge = merge %>% left_join(gene_annot, by = c('gene' = 'gene_id'))
# get_var_pos = function(x) {
#   f = strsplit(x, '_')
#   unlist(lapply(f, function(x) { as.numeric(x[2]) }))
# }
# merge$var_pos = get_var_pos(merge$variant_id)
is_inside = function(s, e, this) {
  this > s & this < e
}
merge = merge %>% mutate(is_in = is_inside(gene_start, gene_end, variant_pos))
merge %>% ggplot() + 
  geom_point(aes(x = log2_aFC, y = bhat.trc / log(2)), alpha = .2) + 
  geom_abline(slope = 1, intercept = 0, color = 'red') + facet_wrap(~chr)
# 
# gene_meta = read.table('~/Desktop/mixqtl-pipeline-results/misc_data/gtex-v8-genes-passed-qc-with-median-trc.txt', header = T)
# 
# clean_indiv = function(s) {
#   unlist(lapply(strsplit(s, '-'), function(x) {
#     paste0(x[1], '-', x[2])
#   }))
# }
# parse_obs = function(x) {
#   ee = unlist(lapply(strsplit(x, '\\|'), function(s) {as.numeric(s[1])}))
#   ff = unlist(lapply(strsplit(x, '\\|'), function(s) {as.numeric(s[2])}))
#   return(list(h1 = ee, h2 = ff))
# }
# 
# phaser = read.table('~/Desktop/mixqtl-pipeline-results/ase_temp.txt', header = T, comment.char = '')
# phaser = phaser[, c(-1, -2, -3, -4)]
# df_phaser = data.frame(obs = as.character(phaser[1, ]), indiv = stringr::str_replace_all(colnames(phaser), '\\.', '-'))
# samples = read.table('~/Desktop/mixqtl-pipeline-results/sample-id-Whole_Blood.txt')
# df_phaser = df_phaser %>% filter(indiv %in% samples$V1)
# e = readRDS('~/Desktop/mixqtl-pipeline-results/input--ENSG00000008128.rds')
# df_phaser = df_phaser %>% mutate(indiv = clean_indiv(indiv))
# library(mixqtl)
# data_collector = e
# geno1 = t(data_collector$geno1)
# geno2 = t(data_collector$geno2)
# class(geno1) = 'numeric'
# class(geno2) = 'numeric'
# is_na = is.na(geno1) | is.na(geno2)
# geno1 = impute_geno(geno1)
# geno2 = impute_geno(geno2)
# geno1[is_na] = (geno1[is_na] + geno2[is_na]) / 2
# geno2[is_na] = geno1[is_na]
# idx = which(colnames(geno1) == 'chr1_1689221_G_A_b38')
# delta_x = geno1[,idx] - geno2[,idx]
# df_delta = data.frame(indiv = names(delta_x), delta_x = as.numeric(delta_x))
# df_phaser = df_phaser %>% inner_join(df_delta, by = 'indiv')
# oo = parse_obs(df_phaser$obs)
# df_phaser = df_phaser %>% mutate(h1 = oo$h1, h2 = oo$h2)
# df_phaser %>% filter(delta_x != 0) %>% mutate(est = log2((h1 + 1) / (h2 + 1)) * delta_x) %>% filter(est != 0) 
