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
df = data.frame(
  y1 = readcount$observed$y1,
  y2 = readcount$observed$y2,
  ystar = readcount$observed$ystar,
  lib_size = readcount$observed$Ti_lib
) %>% mutate(ytotal = y1 + y2 + ystar)


# run mixFine
mod = mixfine(h1, h2, df$y1, df$y2, df$ytotal, df$lib_size, trc_cutoff = 20, asc_cutoff = 2)


# record output
cs = summary(mod)$cs
vars = summary(mod)$vars
vars$beta_true = true_beta[vars$variable]
saveRDS(list(cs = cs, vars = vars), opt$output)

