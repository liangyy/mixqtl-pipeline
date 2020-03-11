f = readRDS('../output/expression/merge-Whole_Blood.rds')
qc = read.table('../../../output/gtex-v8-genes-passed-qc.txt', header = T)
genes = rownames(f$df_trc)
genes = genes[genes %in% qc$gene]


write.table(genes, 'gene_list_whole_blood_with_qc.txt', ro = F, co = F, quo = F)
