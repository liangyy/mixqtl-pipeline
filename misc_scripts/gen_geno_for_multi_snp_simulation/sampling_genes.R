# ARGV1: input gene model file (no header)
# ARGV2: cis window size
# ARGV3: output file name
# ARGV4: number of genes selected

##  'formatted-gene-model.gencode.v32lift37.basic.annotation.txt.gz'

set.seed(1)
library(dplyr)

args = commandArgs(trailingOnly=TRUE)
win_size = as.numeric(args[2])
n = as.numeric(args[4])
df = read.table(args[1], header = F, stringsAsFactors = F)

trim_dot = function(str) {
  f = strsplit(str, '\\.')
  unlist(lapply(f, function(x) { x[1] }))
}

df = df %>% filter(V8 == 'protein_coding') 
df$tss = df$V4
df$tss[df$V6 == '-'] = df$V5[df$V6 == '-']
# df$tss = as.numeric(as.character(df$tss))
df$start = df$tss - win_size
df$end = df$tss + win_size
df$chr = stringr::str_remove(df$V1, 'chr')
df$gene = trim_dot(df$V7)
selected = df[sample(1:nrow(df), size = n, replace = F), ]
write.table(selected %>% select(chr, start, end, gene), args[3], row = F, col = F, sep = '\t', quo = F)
