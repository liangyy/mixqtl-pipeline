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

source('../../code/rlib_simulation.R')

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
df = data.frame(
  y1 = readcount$observed$y1,
  y2 = readcount$observed$y2,
  ystar = readcount$observed$ystar,
  lib_size = readcount$observed$Ti_lib
) %>% mutate(ytotal = y1 + y2 + ystar)


# run mixFine
timer = system.time({
  mod = mixfine(h1, h2, df$y1, df$y2, df$ytotal, df$lib_size, cov_offset = rep(0, nrow(df)), trc_cutoff = 10, asc_cutoff = 5)  # , weight_cap = NULL)
  # mod = tmp$mod
}, gcFirst = T)
  

# record output
cs = summary(mod)$cs
vars = summary(mod)$vars
vars$beta_true = true_beta[vars$variable]
# saveRDS(list(cs = cs, vars = vars, tmp = tmp), opt$output)
saveRDS(list(cs = cs, vars = vars, timer = format_system_time(timer)), opt$output)


