library(optparse)

option_list <- list(
    make_option(c("-i", "--input_peer"), type="character", default=NULL,
                help="output of peertool X.csv",
                metavar="character"),
    make_option(c("-c", "--covariate"), type="character", default=NULL,
                help="covariates (exclude InferCov, which is PEER factors based on normalized expression)",
                metavar="character"),
    make_option(c("-r", "--input_rds"), type="character", default=NULL,
                help="RDS to extract row/colnames only",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character")
)
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(stringr)
# source('scripts/rlib.R')
# r function in rlib.R
dot2dash = function(str) {
  stringr::str_replace(str, '\\.', '-')
}
# END

d = readRDS(opt$input_rds)
peer = as.data.frame(t(read.table(opt$input_peer, sep = ',', header = F)))
npeer = nrow(peer)
colnames(peer) = colnames(d)
ID = paste0('InferredCov', 1 : npeer)
peer = cbind(ID, peer)

other_cov = read.table(opt$covariate, header = T)
colnames(other_cov) = dot2dash(colnames(other_cov))
cov_names = other_cov$ID
not_peer_ind = is.na(str_match(cov_names, 'InferredCov'))
cov_not_peer = other_cov[not_peer_ind, ]
col_both = intersect(colnames(cov_not_peer), colnames(peer))
cov_not_peer = cov_not_peer[, colnames(cov_not_peer) %in% col_both]
peer = peer[, colnames(peer) %in% col_both]
cov_not_peer = cov_not_peer[, match(colnames(peer), colnames(cov_not_peer))]
cov_combined = rbind(peer, cov_not_peer)
write.table(cov_combined, opt$output, row = F, col = T, quo = F, sep = '\t')

