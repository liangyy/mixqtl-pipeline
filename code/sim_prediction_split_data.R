library(optparse)

option_list <- list(
    make_option(c("-n", "--ntest"), type="numeric", default=NULL,
                help="number of test",
                metavar="character"),
    make_option(c("-o", "--output_prefix"), type="character", default=NULL,
                help="output prefix",
                metavar="character"),
    make_option(c("-g", "--geno"), type="character", default=NULL,
                help="genotype (X)",
                metavar="character"),
    make_option(c("-r", "--readcount"), type="character", default=NULL,
                help="readcount (y, group)",
                metavar="character"),
    make_option(c("-a", "--ratio"), type="numeric", default=1/2,
                help="percent for test (default 1/2)",
                metavar="character")

)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

source('../../code/rlib_simulation.R')



# read in genotype, readcount
geno = readRDS(opt$geno)
readcount = readRDS(opt$readcount)[[2]]
# meanTRC = mean(readcount$observe$Y1 + readcount$observe$Y2)
maf = rowMeans(cbind(geno$h1, geno$h2), na.rm = T)
causal_log_betas = readcount$hidden$betas[readcount$hidden$betas != 0]
causal_maf = maf[readcount$hidden$betas != 0]
genetic_var = sum(causal_log_betas ^ 2 * 2 * causal_maf * (1 - causal_maf))

for(i in 1 : opt$ntest) {
  message('test: ', i, '/', opt$ntest)
  # split data
  set.seed(i)
  splitted_data = split_data_here(geno, readcount, opt$ratio)
  # add genetic variation
  splitted_data$genetic_var = genetic_var
  # output filename
  filename = paste0(opt$output_prefix, i, '.rds')
  saveRDS(splitted_data, filename)
}
