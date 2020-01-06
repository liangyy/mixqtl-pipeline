library(optparse)

option_list <- list(
    make_option(c("-g", "--geno"), type="character", default=NULL,
                help="genotype",
                metavar="character"),
    make_option(c("-r", "--readcount"), type="character", default=NULL,
                help="readcount",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(mixqtl)
library(dplyr)


# load data
genotype = readRDS(opt$geno)
readcount = readRDS(opt$readcount)[[2]]

# get true_beta
true_beta = readcount$hidden$betas

# prepare inputs
h1 = genotype$h1
h2 = genotype$h2
class(h1) = 'numeric'
class(h2) = 'numeric'
h1[is.na(h1)] = 0.5
h2[is.na(h2)] = 0.5
X = (h1 + h2) / 2
trc = readcount$observed$y1 + readcount$observed$y2 + readcount$observed$ystar
y = log(trc / 2 / readcount$observed$Ti_lib)


# run trcFine
mod = mixqtl:::run_susie_default(X, y)


# record output
cs = summary(mod)$cs
vars = summary(mod)$vars
vars$beta_true = true_beta[vars$variable]
saveRDS(list(cs = cs, vars = vars), opt$output)

