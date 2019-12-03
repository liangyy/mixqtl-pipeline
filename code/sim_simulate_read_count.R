library(optparse)

option_list <- list(
    make_option(c("-p", "--param"), type="character", default=NULL,
                help="input YAML telling the parameters of simulation",
                metavar="character"),
    make_option(c("-o", "--output_prefix"), type="character", default=NULL,
                help="prefix of output",
                metavar="character"),
    make_option(c("-y", "--genotype"), type="character", default=NULL,
                help="simulated gene file",
                metavar="character"),
    make_option(c("-g", "--gene"), type="character", default=NULL,
                help="simulated genotype file",
                metavar="character"),
    make_option(c("-t", "--type"), type="character", default='single',
                help="specify [single] or [multi] to perform single-snp or milti-snp simulation",
                metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

library(mixqtl)

## load parameter
param = yaml::read_yaml(opt$param)
set.seed(param$seed)

## Pre-fixed parameters
L_read = param$L_read
betas = log(eval(parse(text = param$betas)))  # effect size (log fold change)

# load the gene
gene_param = readRDS(opt$gene)
gene = create_gene(gene_param$L_gene, gene_param$library_dist, gene_param$theta_dist, gene_param$f, gene_param$maf, gene_param$p)

# load genotypes
genotype = readRDS(opt$genotype)
if(opt$type == 'single') {
  fG = genotype$fG
  geno = genotype$genotype
} else if(opt$type == 'multi') {
}

# Simulate reads
data_collector = list()
for(beta in betas) {
  if(opt$type == 'single') {
    df = simulate_read_count(gene, geno, beta, L_read, param$y_dist)
    data_collector[[length(data_collector) + 1]] = list(data = df, fG = fG, beta = beta)
  } else if(opt$type == 'multi') {
  }
}
saveRDS(data_collector, opt$output)
