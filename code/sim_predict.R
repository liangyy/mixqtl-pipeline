library(optparse)

option_list <- list(
    make_option(c("-p", "--predictor"), type="character", default=NULL,
                help="prediction model",
                metavar="character"),
    make_option(c("-t", "--test_data"), type="character", default=NULL,
                help="output prefix",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(data.table)
options(datatable.fread.datatable = F)


# load predictor
data_collector = readRDS(opt$test_data)
mod = readRDS(opt$predictor)
snplist = mod$snplist
beta = mod$model$beta


# prepare inputs
test = data_collector$test
if(!is.null(snplist)) {
  test$genotype = subset_var_here(test$genotype, snplist$SNP)
}


# prepare genotypes 
h1 = test$genotype$h1; h1[is.na(h1)] = 0.5
h2 = test$genotype$h2; h2[is.na(h2)] = 0.5
X = (h1 + h2) / 2


# predict
ypred = X %*% beta[-1]  # excluding intercept term


# prepare log y/lib
trc = test$readcount$observed$y1 + test$readcount$observed$y2 + test$readcount$observed$ystar
y = log(trc / 2 / test$readcount$observed$Ti_lib)


# save results
saveRDS(list(y = y, ypred = ypred, genetic_var = data_collector$genetic_var, training_time = mod$time), opt$output)
