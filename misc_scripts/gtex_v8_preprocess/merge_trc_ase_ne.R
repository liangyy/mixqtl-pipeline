library(optparse)

option_list <- list(
    make_option(c("-t", "--trc"), type="character", default=NULL,
                help="TRC",
                metavar="character"),
    make_option(c("-a", "--ase"), type="character", default=NULL,
                help="ASE",
                metavar="character"),
    make_option(c("-n", "--ne"), type="character", default=NULL,
                help="normalized expression",
                metavar="character"),
    make_option(c("-r", "--output"), type="character", default=NULL,
                help="output rds",
                metavar="character"),
    make_option(c("-l", "--library_size"), type="character", default=NULL,
                help="library_size of samples",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(data.table)
options(datatable.fread.datatable=FALSE)
# source('../../scripts/rlib_minimal_test.R')
# r functions from rlib_minimal_test.R
trim_dot = function(str) {
  unlist(lapply(strsplit(str, '\\.'), function(x) { x[1] }))
}
rearrange_columns = function(df, cols) {
  # rearrange the cols to the first n columns in df
  info_columns = match(cols, colnames(df))
  info_temp = df[, info_columns]
  df = cbind(info_temp, df[, -info_columns])
  return(df)
}
decompose_ase = function(df, cols) {
  df_info = df[, -cols]
  df_ase = df[, cols]
  temp_decomp = t(apply(df_ase, 1, function(x) {
    temp = str_match(x, '([0-9]+)\\|([0-9]+)')
    h1 = as.numeric(temp[, 2])
    h2 = as.numeric(temp[, 3])
    return(c(h1, h2))
  }))
  df_h1 = temp_decomp[, 1 : ncol(df_ase)]
  df_h2 = temp_decomp[, (1 + ncol(df_ase)) : (2 * ncol(df_ase))]
  df_h1 = cbind(df_info, df_h1)
  df_h2 = cbind(df_info, df_h2)
  colnames(df_h1)[cols] = colnames(df_ase)
  colnames(df_h2)[cols] = colnames(df_ase)
  return(list(h1 = df_h1, h2 = df_h2))
}
# END

get_indiv_from_sample = function(sampleid) {
  unlist(lapply(strsplit(sampleid, '-'), function(x) {paste0(x[1], '-', x[2])}))
}
is_par_y = function(str) {
  unlist(lapply(strsplit(str, '_'), function(x) {
    if(length(x) == 1) {
      return(FALSE)
    } else { 
      x[length(x)] == 'Y' & x[length(x) - 1] == 'PAR' 
    }
  }))
}


# load normalized expression data
norm_express = fread(cmd = paste0('zcat ', opt$ne), header = T, sep = '\t')
cols = c('gene_id', '#chr', 'start', 'end')
norm_express = rearrange_columns(norm_express, cols)
norm_express[, 1] = trim_dot(norm_express[, 1])
ne_count = norm_express[, -(1:4)]
ne_gene = norm_express[, 1]

trc = fread(cmd = paste0('zcat ', opt$trc), header = T)
trc = trc[, -ncol(trc)] # trim last column which is empty
cols = c('Name', 'Description')
trc = rearrange_columns(trc, cols)
trc = trc[!is_par_y(trc[, 1]), ]
trc[, 1] = trim_dot(trc[, 1])
trc_gene = trc[, 1]
trc_count = trc[, -(1:2)]
trc_sample = colnames(trc_count)
trc_indiv = get_indiv_from_sample(colnames(trc_count))
colnames(trc_count) = trc_indiv
trc_count = trc_count[, trc_indiv %in% colnames(ne_count)]
trc_sample = trc_sample[trc_indiv %in% colnames(ne_count)]

# load library size
df_ls = fread(opt$library_size, header = T, sep = '\t')
df_ls = df_ls %>% filter(SAMPID %in% trc_sample)
df_ls = df_ls[ match(trc_sample, df_ls$SAMPID), ]
df_ls = df_ls %>% select(SAMPID, SMMPPD) %>% mutate(indiv = get_indiv_from_sample(SAMPID))

ase = fread(cmd = paste0('zcat ', opt$ase), header = T, sep = '\t')
ase = ase[, -ncol(ase)]  # trim last column which is empty
cols = c('GENE_ID')
ase = rearrange_columns(ase, cols)
ase = ase[!duplicated(ase[, 1]), ]
ase[, 1] = trim_dot(ase[, 1])
ase_gene = ase[, 1]
ase_count = ase[, -1]
ase_indiv = get_indiv_from_sample(colnames(ase_count))
colnames(ase_count) = ase_indiv
ase_count = ase_count[, ase_indiv %in% colnames(ne_count)]

gene = intersect(ase_gene, intersect(ne_gene, trc_gene))
indiv = intersect(colnames(ase_count), intersect(colnames(ne_count), colnames(trc_count)))
gene = gene[order(gene)]
indiv = indiv[order(indiv)]

rownames(ne_count) = ne_gene
ne_count = ne_count[, match(indiv, colnames(ne_count))]
ne_count = ne_count[match(gene, rownames(ne_count)), ]

rownames(trc_count) = trc_gene
trc_count = trc_count[, match(indiv, colnames(trc_count))]
trc_count = trc_count[match(gene, rownames(trc_count)), ]

rownames(ase_count) = ase_gene
ase_count = ase_count[, match(indiv, colnames(ase_count))]
ase_count = ase_count[match(gene, rownames(ase_count)), ]

df_ls = df_ls[match(indiv, df_ls$indiv), ]

ase_decomp = decompose_ase(ase_count, 1 : ncol(ase_count))
a1_count = ase_decomp$h1
a2_count = ase_decomp$h2
saveRDS(list(df_trc = trc_count, df_ase1 = a1_count, df_ase2 = a2_count, df_norm_express = ne_count, df_lib = df_ls), opt$output)
