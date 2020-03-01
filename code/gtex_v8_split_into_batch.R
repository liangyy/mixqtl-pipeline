library(optparse)

option_list <- list(
    make_option(c("-e", "--expression"), type="character", default=NULL,
                help="read count matrices (TRC and ASE)",
                metavar="character"),
    make_option(c("-g", "--genotype"), type="character", default=NULL,
                help="variant list in cis-window",
                metavar="character"),
    make_option(c("-o", "--output_prefix"), type="character", default=NULL,
                help="prefix of output",
                metavar="character"),
    make_option(c("-n", "--nbatch"), type="numeric", default=NULL,
                help="number of batches",
                metavar="character"),
    make_option(c("-x", "--gene"), type="character", default=NULL,
                help="name of gene",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(data.table)
library(dplyr)
library(stringr)
options(datatable.fread.datatable=FALSE)
# source('../../scripts/rlib_minimal_test.R')
# source('../../scripts/rlib_generic.R')
trim_dot = function(str) {
  unlist(lapply(strsplit(as.character(str), '\\.'), function(x) { x[1] }))
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
split_batch = function(n, nbatch) {
  o = data.frame()
  if(n >= nbatch) {
    batch_size = floor(n / nbatch)
    for(i in 1 : nbatch) {
      start = 1 + ((i - 1) * batch_size)
      if(i != nbatch) {
        end = i * batch_size
      } else {
        end = nvar
      }
      o = rbind(o, data.frame(start = start, end = end))
    }
  } else {
    batch_size = 1
    start = 1 : n
    end = 1 : n
    start = c(start, rep(NA, nbatch - n))
    end = c(end, rep(NA, nbatch - n))
    o = data.frame(start = start, end = end)
  }
  o
}
# END

datalist = readRDS(opt$expression)
trc = datalist$df_trc
ase1 = datalist$df_ase1
ase2 = datalist$df_ase2
ne = datalist$df_norm_express
lib = datalist$df_lib

# individuals
indiv = colnames(ase1)


# load cis variants
geno = fread(paste0('zcat < ', opt$genotype), header = T)
geno = geno[, -c(1, 2, 4, 5, 6, 7, 8, 9)]
geno = as.data.frame(geno[, c(T, colnames(geno)[-1] %in% indiv)])
geno_as = decompose_ase(geno, 2 : ncol(geno))
geno1 = geno_as$h1
geno2 = geno_as$h2

# overlapped individuals
indiv_selected = indiv[indiv %in% colnames(geno2)[-1]]
variant_name = geno1[, 1]
geno1 = geno1[, -1]; geno1 = geno1[, match(indiv_selected, colnames(geno1))]; rownames(geno1) = variant_name
geno2 = geno2[, -1]; geno2 = geno2[, match(indiv_selected, colnames(geno2))]; rownames(geno2) = variant_name

trc = trc[, match(indiv_selected, colnames(trc))]
ne = ne[, match(indiv_selected, colnames(ne))]
ase1 = ase1[, match(indiv_selected, colnames(ase1))]
ase2 = ase2[, match(indiv_selected, colnames(ase2))]
lib = lib[match(indiv_selected, lib$indiv), ]
nlib = lib$SMMPPD

# gene index
gene_idx = which(trim_dot(trc$name) == trim_dot(opt$gene))
trc_g = as.numeric(trc[which(trim_dot(rownames(trc)) == trim_dot(opt$gene)), ])
ne_g = as.numeric(ne[which(trim_dot(rownames(ne)) == trim_dot(opt$gene)), ])
ase1_g = as.numeric(ase1[which(trim_dot(rownames(ase1)) == trim_dot(opt$gene)), ])
ase2_g = as.numeric(ase2[which(trim_dot(rownames(ase2)) == trim_dot(opt$gene)), ])

nvar = nrow(geno1)
df_split = split_batch(nvar, opt$nbatch)
for(i in 1 : nrow(df_split)) {
  start = df_split$start[i]
  end = df_split$end[i]
  message(start, ' ', end, ' ', nrow(geno1))
  if(!is.na(start)) {
    geno1_b = geno1[start : end, ]
    geno2_b = geno2[start : end, ]
    geno_name = rownames(geno1_b)
  } else {
    geno1_b = NULL
    geno2_b = NULL
    geno_name = NULL
  }
  out = paste0(opt$output_prefix, i, '.rds')
  saveRDS(list(geno1_b = geno1_b, geno2_b = geno2_b, geno_name = geno_name, trc_g = trc_g, ase1_g = ase1_g, ase2_g = ase2_g, ne_g = ne_g, nlib = nlib), out)
}
