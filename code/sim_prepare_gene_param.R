library(optparse)

option_list <- list(
    make_option(c("-p", "--param"), type="character", default=NULL,
                help="input YAML telling the parameters of simulation",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="prefix of output",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(mixqtl)

## load parameter
param = yaml::read_yaml(opt$param)
set.seed(param$seed)

## Pre-fixed parameters
if(is.character(param$L_gene)) {
  L_gene = eval(parse(text = param$L_gene)) 
} else {
  L_gene = param$L_gene
}
library_dist = param$library_dist  # mean library size
if(is.character(param$theta_mu)) {
  theta_mu = eval(parse(text = param$theta_mu))
} else {
  theta_mu = param$theta_mu  # theta_i ~ Beta(a, b), E[theta_i] = theta_mu, Var[theta_i] = theta_sd^2
}
if(is.character(param$theta_sd)) {
  theta_sd = eval(parse(text = param$theta_sd))
} else {
  theta_sd = param$theta_sd
}
theta_dist = list(type = theta_dist, mu = theta_mu, sd = theta_sd)
f = param$f  # frequency of heterozygous sites
maf = c(param$maf_l, param$maf_h) 
p = rep(1, L_gene) / L_gene 

# Generate the gene parameter list
gene = list(L_gene = L_gene, library_dist = library_dist, theta_dist = theta_dist, f = f, maf = maf, p = p)

saveRDS(gene, opt$output)
