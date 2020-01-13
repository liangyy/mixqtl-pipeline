library(optparse)

option_list <- list(
    make_option(c("-f", "--from"), type="numeric", default=NULL,
                help="from idx",
                metavar="character"),
    make_option(c("-t", "--to"), type="numeric", default=NULL,
                help="to index",
                metavar="character"),
    make_option(c("-n", "--ntest"), type="numeric", default=NULL,
                help="number of tests",
                metavar="character"),
    make_option(c("-p", "--input_prefix"), type="character", default=NULL,
                help="prefix of input",
                metavar="character"),
    make_option(c("-m", "--input_middle"), type="character", default=NULL,
                help="middle text of input",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(dplyr)
source('../../code/rlib_simulation.R')

df = data.frame()
for(i in opt$from : opt$to) {
  for(n in 1 : opt$ntest) {
    filename = paste0(opt$input_prefix, i, opt$input_middle, n, '.rds')
    out = readRDS(filename)
    pve = get_pve_here(out$y, out$ypred)
    spearman_correlation = get_spcor_here(out$y, out$ypred)
    pearson_correlation = get_pcor_here(out$y, out$ypred)
    df_sub = data.frame(pve = pve, spearman_correlation = spearman_correlation, pearson_correlation = pearson_correlation, genetic_var = out$genetic_var[1], m = i, replicate = n)
    df_sub = cbind(df_sub, out$training_time)
    df = rbind(df, df_sub)
  }
}
saveRDS(df, opt$output)
