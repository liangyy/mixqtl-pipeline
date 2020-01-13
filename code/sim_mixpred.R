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
                metavar="character")  # ,
    # make_option(c("-t", "--timelog"), type="character", default=NULL,
    #             help="Write time used in file",
    #             metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(data.table)
options(datatable.fread.datatable = F)
library(mixqtl)
library(dplyr)


# prepare inputs
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


# training
timer = system.time({
  mod = mixpred(
    h1, 
    h2, 
    train$readcount$observed$y1, 
    train$readcount$observed$y2, 
    train$readcount$observed$y1 + train$readcount$observed$y2 + train$readcount$observed$ystar,
    train$readcount$observed$Ti_lib, 
    trc_cutoff = 10, 
    asc_cutoff = 5
  )
}, gcFirst = T)


# return
saveRDS(list(model = model, snplist = hm3snp, time = format_system_time(timer)), opt$output)

# 
# # write time used
# if(!is.null(opt$timelog)) {
#   write.table(format_system_time(timer), opt$timelog, col = T, row = F, quo = F, sep = '\t')
# }

