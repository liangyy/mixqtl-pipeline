library(optparse)

option_list <- list(
    make_option(c("-r", "--rds"), type="character", default=NULL,
                help="RDS (input)",
                metavar="character"),
    make_option(c("-c", "--csv"), type="character", default=NULL,
                help="CSV (output)",
                metavar="character")
)
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

d = readRDS(opt$rds)
write.table(t(d), opt$csv, row = F, col = F, quo = F, sep = ',')

