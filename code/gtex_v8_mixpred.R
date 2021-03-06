library(optparse)

option_list <- list(
    make_option(c("-d", "--data"), type="character", default=NULL,
                help="data",
                metavar="character"),
    make_option(c("-o", "--output_perf"), type="character", default=NULL,
                help="output the performance (need to specify indiv_partition to enable this output)",
                metavar="character"),
    make_option(c("-u", "--output_model"), type="character", default=NULL,
                help="output model",
                metavar="character"),
    make_option(c("-c", "--cov"), type="character", default=NULL,
                help="not used",
                metavar="character"),
    make_option(c("-i", "--indiv_partition"), type="character", default=NULL,
                help="partition of indiv id to use",
                metavar="character"),
    make_option(c("-m", "--snplist"), type="character", default=NULL,
                help="If you'd like to limit the prediction to be built using a specific set of SNPs, set the path to the snp list (with column name SNP) here",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(mixqtl)
library(dplyr)
library(stringr)
library(methods)
library(data.table)
options(datatable.fread.datatable=FALSE)
source('../../code/rlib_simulation.R')  # to load evaluation functions

# load data
data_collector = readRDS(opt$data)
nvar = length(data_collector$geno_name)
if(nvar == 0) {
  saveRDS(NULL, opt$output)
  quit()
} else if(nvar == 1) {
  data_collector$geno1 = matrix(data_collector$geno1, nrow = 1)
  data_collector$geno2 = matrix(data_collector$geno2, nrow = 1)
}

if(!is.null(opt$snplist)) {
  hm3snp = fread(opt$snplist, header = T)
  geno_ = list(
    var_name = data_collector$geno_name,
    h1 = data_collector$geno1,
    h2 = data_collector$geno2
  )
  geno_o_ = subset_var_here(train$genotype, hm3snp$SNP)
  data_collector$geno_name = geno_o_$var_name
  data_collector$geno1 = geno_o_$geno1
  data_collector$geno2 = geno_o_$geno2
} 

df_partition = NULL
if(!is.null(opt$indiv_partition)) {
  df_partition = read.table(opt$indiv_partition, header = T, stringsAsFactors = F)
}

if(!is.null(opt$cov)) {
  covariates = fread(opt$cov, header = T)
  covariate_names = str_replace(colnames(covariates), '\\.', '-')
  covariates = cbind(covariates[, 1], covariates[, match(colnames(data_collector$geno1), as.character(covariate_names))])
  indiv_offset = regress_against_covariate(data_collector$trc_g, data_collector$nlib, covariates)
} else {
  indiv_offset = NULL
}


geno1 = t(data_collector$geno1)
geno2 = t(data_collector$geno2)
class(geno1) = 'numeric'
class(geno2) = 'numeric'
is_na = is.na(geno1) | is.na(geno2)
geno1 = impute_geno(geno1)
geno2 = impute_geno(geno2)
geno1[is_na] = (geno1[is_na] + geno2[is_na]) / 2
geno2[is_na] = geno1[is_na]

df = data.frame(y1 = data_collector$ase1_g, y2 = data_collector$ase2_g, trc = data_collector$trc_g, Ti_lib = data_collector$nlib) %>% mutate(y_trc = trc, lib_size = Ti_lib, y_ase1 = y1, y_ase2 = y2)
y = log(df$y_trc / 2 / df$lib_size)
if(!is.null(indiv_offset)) {
  y = y - indiv_offset
}

if(is.null(df_partition)) {
  mod = mixpred(geno1, geno2, df$y1, df$y2, df$y_trc, df$lib_size, cov_offset = indiv_offset, trc_cutoff = 100, asc_cutoff = 50, weight_cap = 10, asc_cap = 1000, nobs_asc_cutoff = 3)
  gz1 = gzfile(opt$output_model, "w")
  write.table(data.frame(beta = mod$beta), gz1, col = T, row = F, quo = F, sep = '\t')
  close(gz1)
} else {
  outlist = list()
  blist = list()
  parts = sort(unique(df_partition$partition))
  for(p in parts) {
    message('working on partition ', p, '/', length(parts))
    indiv_subset = df_partition$indiv[df_partition$partition == p]
    test_ind = colnames(data_collector$geno1) %in% indiv_subset
    train_ind = ! test_ind
    mod = mixpred(
      geno1[train_ind, , drop = FALSE], 
      geno2[train_ind, , drop = FALSE], 
      df$y1[train_ind], 
      df$y2[train_ind], 
      df$y_trc[train_ind], 
      df$lib_size[train_ind], 
      cov_offset = indiv_offset[train_ind], 
      trc_cutoff = 0,  # 100, 
      asc_cutoff = 0,  # 50, 
      # weight_cap = 10, 
      # asc_cap = 1000, 
      nobs_asc_cutoff = 3,
      intercept = T, 
      standardize = T
    )
    Xtest = (geno1[test_ind, , drop = FALSE] + geno2[test_ind, , drop = FALSE]) / 2 
    ypred = Xtest %*% mod$beta[-1]
    yobs = y[test_ind]
    pve = get_pve_here(yobs, ypred)
    spearman_correlation = get_spcor_here(yobs, ypred)
    pearson_correlation = get_pcor_here(yobs, ypred)
    df_sub = data.frame(
      pve = pve, 
      spearman_correlation = spearman_correlation, 
      pearson_correlation = pearson_correlation,
      partition = p
    )
    outlist[[length(outlist) + 1]] = df_sub
    blist[[length(blist) + 1]] = data.frame(beta = mod$beta, partition = p)
  }
  out = do.call(rbind, outlist)
  bout = do.call(rbind, blist)
  gz1 = gzfile(opt$output_model, "w")
  write.table(bout, gz1, col = T, row = F, quo = F, sep = '\t')
  close(gz1)
  gz1 = gzfile(opt$output_perf, "w")
  write.table(out, gz1, col = T, row = F, quo = F, sep = '\t')
  close(gz1)
}




