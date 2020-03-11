library(optparse)

option_list <- list(
    make_option(c("-w", "--wasp"), type="character", default=NULL,
                help="WASP by individual",
                metavar="character"),
    make_option(c("-g", "--gene"), type="character", default=NULL,
                help="gene list",
                metavar="character"),
    make_option(c("-s", "--sample"), type="character", default=NULL,
                help="nsample list",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character"),
    make_option(c("-i", "--indiv"), type="character", default=NULL,
                help="individual ID",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

get_haplo = function(ref, alt, geno) {
  h1 = ref
  h2 = alt
  flip_ind = geno == 'GT;1|0'
  h1_should_be_h2 = h1[flip_ind]
  h2_should_be_h1 = h2[flip_ind]
  h1[flip_ind] = h2_should_be_h1
  h2[flip_ind] = h1_should_be_h2
  return(list(h1 = h1, h2 = h2))
}

get_indiv_id = function(sample) {
  unlist(lapply(strsplit(sample, '-'), function(x) { paste0(x[1], '-', x[2]) }))
}

trim_dot = function(str) {
  unlist(lapply(strsplit(str, '\\.'), function(x) { x[1] }))
}

library(data.table)
options(datatable.fread.datatable = F)
library(dplyr)

gene = fread(opt$gene, header = F)
gene = trim_dot(gene$V1)
sample = fread(opt$sample, header = F)
sample = sample$V1
wasp = fread(cmd = paste0('zcat ', opt$wasp), header = T, sep = '\t')
wasp = wasp %>% filter(!is.na(GENE_ID), GENOTYPE %in% c('GT;0|1', 'GT;1|0'), get_indiv_id(SAMPLE_ID) == opt$indiv) %>% filter(GENE_ID %in% gene, SAMPLE_ID %in% sample)
out = get_haplo(wasp$REF_COUNT, wasp$ALT_COUNT, wasp$GENOTYPE)
wasp$h1 = out$h1; wasp$h2 = out$h2
wasp_gene_level = wasp %>% group_by(GENE_ID, SAMPLE_ID) %>% summarize(h1 = sum(h1), h2 = sum(h2)) %>% ungroup() %>% mutate(ase = paste0(h1, '|', h2)) %>% select(GENE_ID, SAMPLE_ID, ase)
mat = dcast(GENE_ID ~ SAMPLE_ID, value.var = 'ase', data = wasp_gene_level)
mat[is.na(mat)] = '0|0'

not_included_genes = gene[!gene %in% mat$GENE_ID]
if(length(not_included_genes) > 0) {
  mat_add = matrix('0|0', ncol = ncol(mat), nrow = length(not_included_genes))
  mat_add[, 1] = not_included_genes
  colnames(mat_add) = colnames(mat)
  mat = rbind(mat, mat_add)
}
indiv_samples = sample[get_indiv_id(sample) == opt$indiv]
not_included_samples = indiv_samples[!indiv_samples %in% colnames(mat)[-1]]
if(length(not_included_samples) > 0) {
  mat_add = matrix('0|0', nrow = nrow(mat), ncol = length(not_included_samples))
  colnames(mat_add) = not_included_samples
  mat = cbind(mat, mat_add)
}
mat = mat[match(gene, mat[, 1]), ]
gz1 <- gzfile(opt$output, "w")
write.table(mat, gz1, col = T, row = F, quo = F, sep = '\t')
close(gz1)
