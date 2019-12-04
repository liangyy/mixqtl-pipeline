# ARGV1: input gene model file (no header)
# ARGV2: cis window size
# ARGV3: output file name

##  'formatted-gene-model.gencode.v32lift37.basic.annotation.txt.gz'

set.seed(1)
library(dplyr)

args = commandArgs(trailingOnly=TRUE)
df = read.table(args[1], header = F, stringsAsFactors = F)

trim_dot = function(str) {
  f = strsplit(str, '\\.')
  unlist(lapply(f, function(x) { x[1] }))
}

df = df %>% filter(V8 == 'protein_coding') 
df$tss = df$V4
df$tss[df$V6 == '-'] = df$V5[df$V6 == '-']
df$start = df$tss - args[2]
df$end = df$tss + args[2]
df$chr = stringr::str_remove(df$V1, 'chr')
df$gene = trim_dot(df$V7)
write.table(df %>% select(chr, start, end, gene), args[3]), row = F, col = F, sep = '\t', quo = F)
