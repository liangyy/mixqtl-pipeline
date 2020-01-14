library(optparse)

option_list <- list(
    make_option(c("-p", "--param"), type="character", default=NULL,
                help="input YAML telling the parameters of simulation",
                metavar="character"),
    make_option(c("-o", "--output_prefix"), type="character", default=NULL,
                help="prefix of output",
                metavar="character"),
    make_option(c("-n", "--nreplicate"), type="numeric", default=NULL,
                help="number of replicates",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(mixqtl)

## load parameter
param = yaml::read_yaml(opt$param)
# set.seed(param$seed)

## Sample size and number of replications
N = param$Nsample  # number of individuals
M = opt$nreplicate  # number of replicates (fixing gene characteristics and change genetic effect)

## Pre-fixed parameters
maf = c(param$maf_l, param$maf_h)  # MAF range of all variants in the simulation

# Simulate genotype
out = create_genotype(maf, N, M)

# Save
for(m in 1 : M) {  # iterate over replicates
  saveRDS(out[[m]], paste0(opt$output_prefix, m, '.rds'))
}
