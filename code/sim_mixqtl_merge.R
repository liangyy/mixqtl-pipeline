library(optparse)

option_list <- list(
    make_option(c("-p", "--input_prefix"), type="character", default=NULL,
                help="prefix of input",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character"),
    make_option(c("-f", "--from"), type="numeric", default=NULL,
                help="from index",
                metavar="character"),
    make_option(c("-t", "--to"), type="numeric", default=NULL,
                help="to index",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)


collector = data.frame()
for(i in opt$from : opt$to) {
  df = readRDS(paste0(opt$input_prefix, i, '.rds'))
  collector = rbind(collector, df)
}

gz = gzfile(opt$output, 'w')
write.table(collector, gz, row.names = F, quote = F, sep = '\t')
close(gz)
