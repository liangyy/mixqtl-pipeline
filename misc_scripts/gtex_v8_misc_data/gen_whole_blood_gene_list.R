f = readRDS('../output/expression/merge-Whole_Blood.rds')
write.table(rownames(f$df_trc), 'gene_list_whole_blood.txt', ro = F, co = F, quo = F)
