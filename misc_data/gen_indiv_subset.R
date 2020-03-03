library(optparse)

option_list <- list(
    make_option(c("-i", "--input"), type="character", default=NULL,
                help="covariate file used to extract individual ID",
                metavar="character"),
    make_option(c("-o", "--output_prefix"), type="character", default=NULL,
                help="prefix of output",
                metavar="character"),
    make_option(c("-n", "--nrepeat"), type="numeric", default=100,
                help="number of replicate",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(stringr)
library(data.table)
options(datatable.fread.datatable=FALSE)

set.seed(2020)

covariates = fread(opt$input, header = T)
covariate_names = str_replace(colnames(covariates), '\\.', '-')
nindiv = length(covariate_names)

# output_prefix = 'indiv_subset_for_whole_blood'

fraction = 3 : 9 / 10
for(f in fraction) {
  for(i in 1 : opt$nrepeat) {
    nindiv_sub = round(nindiv * f)
    selected = sample(1 : nindiv, size = nindiv_sub, replace = F)
    indiv_sub = covariate_names[selected]
    write.table(indiv_sub, paste0(opt$output_prefix, '__fraction', f, '__batch', i, '.txt'), col = F, row = F, quo = F)
  }
}
