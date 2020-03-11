library(optparse)

option_list <- list(
    make_option(c("-e", "--expression"), type="character", default=NULL,
                help="read count matrices (TRC and ASE)",
                metavar="character"),
    make_option(c("-g", "--genotype"), type="character", default=NULL,
                help="variant list in cis-window",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="filename of output",
                metavar="character"),
    make_option(c("-x", "--gene"), type="character", default=NULL,
                help="name of gene",
                metavar="character"),
    make_option(c("-p", "--output_prefix"), type="character", default=NULL,
                help="prefix of output",
                metavar="character"),
    make_option(c("-y", "--genelist"), type="character", default=NULL,
                help="list of gene names",
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
# R functions in the scripts
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
# END

# load TRC, ASE, L, alpha RDS
datalist = readRDS(opt$expression)
trc = datalist$df_trc
ase1 = datalist$df_ase1
ase2 = datalist$df_ase2
ne = datalist$df_norm_express
lib = datalist$df_lib

# individuals
indiv = colnames(ase1)

# loop over gene
if(!is.null(opt$genelist)) {
  genes = read.table(opt$genelist, header = F, stringsAsFactors = F)
  for(g in genes$V1) {
    message(g)
    this_gene = g
    input_genotype = strsplit(opt$genotype, '\\{gene\\}')[[1]]
    input_genotype = paste0(input_genotype[1], this_gene, input_genotype[2])
    # load cis variants
    geno = fread(paste0('zcat < ', input_genotype), header = T)
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
    # this_gene = g
    gene_idx = which(trim_dot(trc$name) == trim_dot(this_gene))
    trc_g = as.numeric(trc[which(trim_dot(rownames(trc)) == trim_dot(this_gene)), ])
    ne_g = as.numeric(ne[which(trim_dot(rownames(ne)) == trim_dot(this_gene)), ])
    ase1_g = as.numeric(ase1[which(trim_dot(rownames(ase1)) == trim_dot(this_gene)), ])
    ase2_g = as.numeric(ase2[which(trim_dot(rownames(ase2)) == trim_dot(this_gene)), ])

    nvar = nrow(geno1)
    geno_name = rownames(geno1)
    outname = strsplit(opt$output, '\\{gene\\}')[[1]]
    outname = paste0(outname[1], this_gene, outname[2])
    saveRDS(list(geno1 = geno1, geno2 = geno2, geno_name = geno_name, trc_g = trc_g, ase1_g = ase1_g, ase2_g = ase2_g, ne_g = ne_g, nlib = nlib), outname)
  }
} else if(!is.null(opt$gene)) {
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

  gene_idx = which(trim_dot(trc$name) == trim_dot(opt$gene))
  trc_g = as.numeric(trc[which(trim_dot(rownames(trc)) == trim_dot(opt$gene)), ])
  ne_g = as.numeric(ne[which(trim_dot(rownames(ne)) == trim_dot(opt$gene)), ])
  ase1_g = as.numeric(ase1[which(trim_dot(rownames(ase1)) == trim_dot(opt$gene)), ])
  ase2_g = as.numeric(ase2[which(trim_dot(rownames(ase2)) == trim_dot(opt$gene)), ])

  nvar = nrow(geno1)
  geno_name = rownames(geno1)
  saveRDS(list(geno1 = geno1, geno2 = geno2, geno_name = geno_name, trc_g = trc_g, ase1_g = ase1_g, ase2_g = ase2_g, ne_g = ne_g, nlib = nlib), opt$output)
}
