library(optparse)

option_list <- list(
    make_option(c("-d", "--data"), type="character", default=NULL,
                help="data",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character"),
    make_option(c("-c", "--cov"), type="character", default=NULL,
                help="covariate file",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# source('../../scripts/rlib_implement_three_strategies.R')
# source('../../scripts/rlib_minimal_test.R')
# source('../../scripts/rlib_matrix_ls.R')
# R function in the scripts
impute_geno = function(x) {
  mx = colMeans(x, na.rm = T)
  if(length(mx) == 1) {
    x[is.na(x)] = mx
    return(x)
  } 
  t(apply(x, 1, function(x) {
    x[is.na(x)] = mx[is.na(x)]
    return(x)
  }))
}
# END

library(stringr)
library(dplyr)
library(methods)
library(data.table)
options(datatable.fread.datatable=FALSE)
library(mixqtl)

# load data
data_collector = readRDS(opt$data)
nvar = length(data_collector$geno_name)
if(nvar == 0) {
  saveRDS(NULL, opt$output)
  quit()
} else if(nvar == 1) {
  data_collector$geno1_b = matrix(data_collector$geno1_b, nrow = 1)
  data_collector$geno2_b = matrix(data_collector$geno2_b, nrow = 1)
}


# impute happens here
data_collector$trc_g[data_collector$trc_g == 0] = 1
# END

if(!is.null(opt$cov)) {
  covariates = fread(opt$cov, header = T)
  covariate_names = str_replace(colnames(covariates), '\\.', '-')
  covariates = cbind(covariates[, 1], covariates[, match(colnames(data_collector$geno1_b), as.character(covariate_names))])
  indiv_offset = regress_against_covariate(data_collector$trc_g, data_collector$nlib, covariates)
} else {
  indiv_offset = NULL
}


geno1 = t(data_collector$geno1_b)
geno2 = t(data_collector$geno2_b)
class(geno1) = 'numeric'
class(geno2) = 'numeric'
is_na = is.na(geno1) | is.na(geno2)
geno1 = impute_geno(geno1)
geno2 = impute_geno(geno2)
geno1[is_na] = (geno1[is_na] + geno2[is_na]) / 2
geno2[is_na] = geno1[is_na]

df = data.frame(y1 = data_collector$ase1_g, y2 = data_collector$ase2_g, trc = data_collector$trc_g, Ti_lib = data_collector$nlib) %>% mutate(y_trc = trc, lib_size = Ti_lib, y_ase1 = y1, y_ase2 = y2)


mix_estimate = mixqtl(geno1, geno2, df$y_ase1, df$y_ase2, df$y_trc, df$lib_size, cov_offset = indiv_offset, trc_cutoff = 1, asc_cutoff = 1, weight_cap = 10, asc_cap = 1000)
mix_estimate$variant_id = data_collector$geno_name

saveRDS(mix_estimate, opt$output)

