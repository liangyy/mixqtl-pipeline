library(optparse)

option_list <- list(
    make_option(c("-i", "--input"), type="character", default=NULL,
                help="covariate file used to extract individual ID",
                metavar="character"),
    make_option(c("-o", "--output_prefix"), type="character", default=NULL,
                help="prefix of output",
                metavar="character"),
    make_option(c("-n", "--npartition"), type="numeric", default=100,
                help="number of partition",
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

n = opt$npartition
min_size_per_part = floor(nindiv / n)
off_size = nindiv - min_size_per_part * n
size_per_part = rep(min_size_per_part, n)
if(off_size > 0) {
  size_per_part[1 : off_size] = size_per_part[1 : off_size] + 1
}
part_labels = c()
for(i in 1 : length(size_per_part)) {
  part_labels = c(part_labels, rep(i, size_per_part[i]))
}
random_partition = part_labels[sample(1 : nindiv)]
out = data.frame(indiv = covariate_names, partition = random_partition)


write.table(out, paste0(opt$output_prefix, '.partition_', n, '.txt'), col = T, row = F, quo = F)

