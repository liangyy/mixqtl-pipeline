library(optparse)

option_list <- list(
    make_option(c("-d", "--data"), type="character", default=NULL,
                help="data",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character"),
    make_option(c("-m", "--snplist"), type="character", default=NULL,
                help="If you'd like to limit the prediction to be built using a specific set of SNPs, set the path to the snp list (with column name SNP) here",
                metavar="character")  
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(data.table)
options(datatable.fread.datatable = F)
library(mixqtl)
library(dplyr)

source('../../code/rlib_simulation.R')



# prepare inputs
data_collector = readRDS(opt$data)
train = data_collector$train
if(!is.null(opt$snplist)) {
  hm3snp = fread(opt$snplist, header = T)
  train$genotype = subset_var_here(train$genotype, hm3snp$SNP)
} else {
  hm3snp = NULL
}


# prepare genotypes 
h1 = train$genotype$h1; h1[is.na(h1)] = 0.5
h2 = train$genotype$h2; h2[is.na(h2)] = 0.5
X = (h1 + h2) / 2
trc = train$readcount$observed$y1 + train$readcount$observed$y2 + train$readcount$observed$ystar
y = log(trc / 2 / train$readcount$observed$Ti_lib)


# training
timer = system.time({
  mod = mixqtl:::fit_glmnet_with_cv(
    X, y, intercept = T, standardize = F
  )
}, gcFirst = T)


# return
saveRDS(list(model = mod, snplist = hm3snp, time = format_system_time(timer)), opt$output)

# 
# # write time used
# if(!is.null(opt$timelog)) {
#   write.table(format_system_time(timer), opt$timelog, col = T, row = F, quo = F, sep = '\t')
# }

