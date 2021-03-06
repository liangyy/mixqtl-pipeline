library(optparse)

option_list <- list(
    make_option(c("-d", "--data"), type="character", default=NULL,
                help="data",
                metavar="character"),
    make_option(c("-o", "--output_cs"), type="character", default=NULL,
                help="output on CS",
                metavar="character"),
    make_option(c("-u", "--output_pip"), type="character", default=NULL,
                help="output on PIP",
                metavar="character"),
    make_option(c("-c", "--cov"), type="character", default=NULL,
                help="not used",
                metavar="character"),
    make_option(c("-i", "--indiv_subset"), type="character", default=NULL,
                help="list of indiv id to use",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(mixqtl)
library(stringr)
library(dplyr)
library(methods)
library(data.table)
options(datatable.fread.datatable=FALSE)

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

if(!is.null(opt$indiv_subset)) {
  indiv_subset = read.table(opt$indiv_subset, header = F, stringsAsFactors = F)$V1
  sub_ind = colnames(data_collector$geno1) %in% indiv_subset
  data_collector$geno1 = data_collector$geno1[, sub_ind]
  data_collector$geno2 = data_collector$geno2[, sub_ind]
  data_collector$trc_g = data_collector$trc_g[sub_ind]
  data_collector$ase1_g = data_collector$ase1_g[sub_ind]
  data_collector$ase2_g = data_collector$ase2_g[sub_ind]
  data_collector$ne_g = data_collector$ne_g[sub_ind]
  data_collector$nlib = data_collector$nlib[sub_ind]
}

if(!is.null(opt$cov)) {
  covariates = fread(opt$cov, header = T)
  covariate_names = str_replace(colnames(covariates), '\\.', '-')
  covariates = cbind(covariates[, 1], covariates[, match(colnames(data_collector$geno1), as.character(covariate_names))])
  indiv_offset = regress_against_covariate(data_collector$ne_g, NULL, covariates)
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

df = data.frame(y = data_collector$ne_g)
if(!is.null(indiv_offset)) {
  df$y = df$y - indiv_offset
}


mod = mixqtl:::run_susie_default(x = geno1 + geno2, y = df$y)
if('cs' %in% names(mod)) {
  cs = mod$cs
  vars = mod$vars
  vars$variant_id = data_collector$geno_name[vars$variable]
} else {
  vars = summary(mod)$vars
  vars$variant_id = data_collector$geno_name[vars$variable]
  cs = summary(mod)$cs
}


gz1 = gzfile(opt$output_pip, "w")
write.table(vars, gz1, col = T, row = F, quo = F, sep = '\t')
close(gz1)

gz1 = gzfile(opt$output_cs, "w")
write.table(cs, gz1, col = T, row = F, quo = F, sep = '\t')
close(gz1)

