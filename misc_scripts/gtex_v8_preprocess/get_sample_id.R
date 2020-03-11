library(optparse)

option_list <- list(
    make_option(c("-t", "--table"), type="character", default=NULL,
                help="table to query from",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character"),
    make_option(c("-i", "--tissue"), type="character", default=NULL,
                help="name of tissue",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(data.table)
library(stringr)
library(ggplot2)
library(dplyr)

sample_info = fread(opt$table, header = T)
tissue_samples = sample_info %>% filter(SMTSD == opt$tissue)
write.table(tissue_samples$SAMPID, file = opt$output, row.names = F, col.names = F, quote = F)
