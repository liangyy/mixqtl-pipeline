library(optparse)

option_list <- list(
    make_option(c("-n", "--number_total"), type="numeric", default=NULL,
                help="size of total sample",
                metavar="character"),
    make_option(c("-u", "--number_sub"), type="character", default=NULL,
                help="size of sub-sample",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

set.seed(1)

idx = sample(1 : opt$number_total, size = opt$number_sub, replace = F)
write.table(idx, opt$output, row = F, col = F, quo = F, sep = '\t')
