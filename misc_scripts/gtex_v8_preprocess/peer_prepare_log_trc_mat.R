library(optparse)

option_list <- list(
    make_option(c("-i", "--input"), type="character", default=NULL,
                help="data",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# This script prepare expression matrix for PEER factor workflow suggested here: https://www.nature.com/articles/nprot.2011.457

# Get expression matrix

## each entry is log(TRC / 2)
r = readRDS(opt$input)
mat = r$df_trc
lib = r$df_lib
mat = sweep(mat, 2, lib$SMMPPD, FUN = '/')
mat = log(mat / 2)
mat[r$df_trc == 0] = NA

## Impute missing cells as suggested in paper
mat_imp = impute::impute.knn(as.matrix(mat))
saveRDS(as.matrix(mat_imp$data), opt$output)
