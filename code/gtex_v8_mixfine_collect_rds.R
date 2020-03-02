library(optparse)

option_list <- list(
    make_option(c("-p", "--prefix_cs"), type="character", default=NULL,
                help="prefix of CS input",
                metavar="character"),
    make_option(c("-r", "--prefix_pip"), type="character", default=NULL,
                help="prefix of PIP input",
                metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL,
                help="output",
                metavar="character"),
    make_option(c("-g", "--genelist"), type="character", default=NULL,
                help="gene list",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(dplyr)
library(methods)
library(data.table)
options(datatable.fread.datatable=FALSE)

cs = data.frame()
pip = data.frame()
genes = c()

genelist = read.table(opt$genelist, header = F, stringsAsFactors = F)



for(g in genelist$V1) {
  cfile = paste0(opt$prefix_cs, g, '.txt.gz')
  pfile = paste0(opt$prefix_pip, g, '.txt.gz')
  if(!(file.exists(cfile) & file.exists(pfile))) {
    next
  }
  message(cfile)
  genes = c(genes, g)
  ctemp = tryCatch({
    fread(cmd = paste0('zcat ', cfile), header = T)
  }, error = function(e) {
    data.frame()
  }
  )
  if(nrow(ctemp) == 0) {
    next
  }
  ctemp$gene = g
  cs = rbind(cs, ctemp)
  ptemp = fread(cmd = paste0('zcat ', pfile), header = T)
  ptemp = ptemp %>% filter(cs != -1)
  ptemp$gene = g
  pip = rbind(pip, ptemp)
}

saveRDS(list(pip = pip, cs = cs, genes = genes), opt$output)
