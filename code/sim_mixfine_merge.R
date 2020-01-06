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


cs = data.frame()
vars = data.frame()
for(i in opt$from : opt$to) {
  filename = paste0(opt$prefix, i, '.rds')
  df_sub = readRDS(filename)
  if(!is.null(ncol(df_sub$vars))) {
    df_sub$vars$simulation =i
    vars = rbind(vars, df_sub$vars)
  }
  if(!is.null(ncol(df_sub$cs))) {
    df_sub$cs$simulation =i
    cs = rbind(cs, df_sub$cs)
  }
}
saveRDS(list(vars = vars, cs = cs), opt$output)

