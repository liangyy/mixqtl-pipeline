library(optparse)

option_list <- list(
    make_option(c("-d", "--data"), type="character", default=NULL,
                help="data",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(mixqtl)
library(dplyr)

# load data
data_collector = readRDS(opt$data)

# run test for all data sets
out_collector = data.frame()
for(i in 1 : length(data_collector)) {
  df = data_collector[[i]]$data
  fG = data_collector[[i]]$fG
  beta = data_collector[[i]]$beta
  df_obs = df$observed

  geno1 = matrix(df_obs$Gi1, ncol = 1)
  geno2 = matrix(df_obs$Gi2, ncol = 1)
  class(geno1) = 'numeric'
  class(geno2) = 'numeric'
  geno1 = impute_geno(geno1)
  geno2 = impute_geno(geno2)

  df_obs = df_obs %>% mutate(y_trc = y1 + y2 + ystar, y_ase1 = y1, y_ase2 = y2, lib_size = Ti_lib, indiv_cov = 0)

  mix = mixqtl(
    geno1 = geno1,
    geno2 = geno2,
    y1 = df_obs$y_ase1,
    y2 = df_obs$y_ase2,
    ytotal = df_obs$y_trc,
    lib_size = df_obs$lib_size,
    trc_cutoff = 20,
    asc_cutoff = 10
  )

  mix$beta = beta
  mix$fG = fG
  out_collector = rbind(out_collector, mix)
}
saveRDS(out_collector, opt$output)
