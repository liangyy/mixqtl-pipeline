library(optparse)

option_list <- list(
    make_option(c("-i", "--input"), type="character", default=NULL,
                help="input genotype TXT GZ",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character"),
    make_option(c("-d", "--indiv"), type="character", default=NULL,
                help="list of individual ID",
                metavar="character"),
    make_option(c("-n", "--nsample"), type="numeric", default=NULL,
                help="number of samples",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(data.table)
library(dplyr)
library(stringr)
options(datatable.fread.datatable=FALSE)
source('../../code/rlib_simulation.R')
set.seed(1)

# load individuals
indiv = read.table(opt$indiv, header = F)
# indiv = str_extract(indiv$V1, '[0-9A-Za-z]+-[0-9A-Za-z]+')

# load genotype
geno = fread(paste0('zcat < ', opt$input), header = T)
var_name = geno[, 3]
geno = geno[, -c(1, 2, 3, 4, 5, 6, 7, 8, 9)]
geno = as.data.frame(geno[, c(colnames(geno) %in% indiv)])
geno_as = decompose_ase(geno, 1 : ncol(geno))
geno1 = geno_as$h1
geno2 = geno_as$h2

## load parameter
sample_size = opt$nsample
selected_idx = sample(1 : ncol(geno1), size = sample_size, replace = F)
geno1 = geno1[, selected_idx]
geno2 = geno2[, selected_idx]

saveRDS(list(h1 = t(geno1), h2 = t(geno2), var_name = var_name), opt$output)
