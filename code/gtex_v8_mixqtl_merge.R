library(optparse)

option_list <- list(
    make_option(c("-i", "--input_prefix"), type="character", default=NULL,
                help="input data prefix",
                metavar="character"),
    make_option(c("-n", "--nbatch"), type="numeric", default=NULL,
                help="number of batch",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

collector = data.frame()
for(i in 1 : opt$nbatch) {
  out = readRDS(paste0(opt$input_prefix, i, '.rds'))
  collector = rbind(collector, out)
}
gz <- gzfile(opt$output, 'w')
write.table(collector, gz, row.names = F, quote = F, sep = '\t')
close(gz)
