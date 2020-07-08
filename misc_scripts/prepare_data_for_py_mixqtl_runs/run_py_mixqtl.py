import argparse
parser = argparse.ArgumentParser(prog='run_py_mixqtl.py', description='''
    Prepare the bundle of input matrices for py-mixqtl run
''')
parser.add_argument('--hap-file', help='''
    the genotype files in parquet format. 
    It assumes that two haplotypes are separate
    and the filename should be like 
    filename.hap{}.parquet.
    Inside, '{}' will be replaced by 1 and 2
    for the two haplotypes.
''')
parser.add_argument('--gene-list', default=None, help='''
    specify a list of gene to map:
    filname:gene_col
''')
parser.add_argument('--libsize', help='''
    library size (specify sample and size columns):
    filename:sample_col:size_col.
    (formatted by prepare_matrices.py)
''')
parser.add_argument('--covariate-matrix', help='''
    covariate matrix 
    (formatted by prepare_matrices.py)
''')
parser.add_argument('--asc-matrix', help='''
    alelle-specific count matrix
    (specify gene column):
    filename:gene_col
    (formatted by prepare_matrices.py).
    Similarly, use '{}' to point to 
    the two haplotypes.
''')
parser.add_argument('--trc-matrix', help='''
    total count matrix 
    (formatted by prepare_matrices.py).
''')
parser.add_argument('--param-yaml', default=1, help='''
    yaml file to specify parameters for mixqtl run.
    Will be put as **kwargs in mixqtl call.
''')
parser.add_argument('--out-dir', help='''
    directory of output (if not exists, it will be created)
''')
parser.add_argument('--out-prefix', help='''
    directory of output prefix
''')
parser.add_argument('--tensorqtl', help='''
    at this point, point to the tensorqtl code folder.
''')
parser.add_argument('--chr', type=str, help='''
    specify chromosome
''')
parser.add_argument('--nthread', type=int, default=1, help='''
    number of threads
''')
parser.add_argument('--impute-trc', action='store_true', help='''
    add it if want to impute zero trc as one.
''')
args = parser.parse_args()


import logging, time, sys
# configing util
logging.basicConfig(
    level = logging.INFO, 
    stream = sys.stderr, 
    format = '%(asctime)s  %(message)s',
    datefmt = '%Y-%m-%d %I:%M:%S %p'
)

import yaml
def load_yaml(f):
    with open(f, 'r') as stream:
        data_loaded = yaml.safe_load(stream)
    return data_loaded

def filter_by_gene_list(gene_list, trc, asc1, asc2, pos_df):
    gene_list_no_dot = [ i.split('.')[0] for i in gene_list ]
    isin = np.isin(phenotype_pos_df.index.to_list(), gene_list_no_dot)
    trc = filter_by_all(
        trc,
        [isin]
    )
    asc1 = filter_by_all(
        asc1,
        [isin]
    )
    asc2 = filter_by_all(
        asc2,
        [isin]
    )
    pos_df = filter_by_all(
        pos_df,
        [isin]
    )
    return trc, asc1, asc2, pos_df
def filter_by_all(df, llogical):
    fl = llogical[0]
    for i in range(1, len(llogical)):
        fl = np.logical_and(fl, llogical[i])
    df = df.loc[fl, :]
    return df

import pandas as pd
import numpy as np
import scipy.stats as stats
import torch
import os

## setup number of threads for torch
torch.set_num_threads(args.nthread)

## floating around dependency
sys.path.insert(0, args.tensorqtl)
import mixqtl
import tensorqtl
## 

# input files
## genotypes
hap1_file = args.hap_file.format(1)
hap2_file = args.hap_file.format(2)
## total count matrix
trc_bed_file = args.trc_matrix
## library size
lib_file_ = args.libsize.split(':')
lib_file = lib_file_[0]
sample_col = lib_file_[1]
size_col = lib_file_[2]
## allele-specific count matrix
asc_ = args.asc_matrix.split(':')
asc1_file = asc_[0].format(1)
asc2_file = asc_[0].format(2)
asc_gene_col = asc_[1]
## covariate matrix
covar_file = args.covariate_matrix

# output
output_prefix = args.out_prefix
outdir = args.out_dir
if not (os.path.exists(outdir) and os.path.isdir(outdir)):
    os.mkdir(outdir)


# load parameters for mixqtl
param_mixqtl = load_yaml(args.param_yaml)

# main run
# load genotypes
logging.info('Load genotypes')
hap1_df = pd.read_parquet(hap1_file)
hap2_df = pd.read_parquet(hap2_file)
variant_df = pd.DataFrame(
    {
        'chrom':hap1_df.index.map(lambda x: x.split('_')[0]),
        'pos':  hap1_df.index.map(lambda x: int(x.split('_')[1]))
    }, 
    index=hap1_df.index
)

# load total counts and library size
logging.info('Load total counts and library size')
phenotype_df, phenotype_pos_df = tensorqtl.read_phenotype_bed(trc_bed_file)
if args.impute_trc is True:
    phenotype_df = phenotype_df + 1
libsize_df = pd.read_csv(lib_file, header = 0, sep = '\t', compression = 'gzip')
libsize_df = libsize_df.set_index(sample_col)
libsize_s = libsize_df.loc[phenotype_df.columns.tolist(), size_col]
## compute log(count / libsize / 2)
log_counts_df = np.log(phenotype_df / libsize_s / 2)
log_counts_df = log_counts_df.loc[phenotype_df.index]
log_counts_df[log_counts_df == -np.Inf] = np.NaN

# load allele-specific counts
logging.info('Load allele-specific counts')
ref_df = pd.read_csv(asc1_file, sep = '\t', compression = 'gzip', header = 0)
alt_df = pd.read_csv(asc2_file, sep = '\t', compression = 'gzip', header = 0)

ref_df = ref_df.set_index(asc_gene_col)
alt_df = alt_df.set_index(asc_gene_col)

ref_df = ref_df.loc[~ref_df.index.duplicated(keep = 'first')]
alt_df = alt_df.loc[~alt_df.index.duplicated(keep = 'first')]

ref_df = ref_df.loc[:, phenotype_df.columns.to_list()]
alt_df = alt_df.loc[:, phenotype_df.columns.to_list()]

ref_df = ref_df.loc[phenotype_df.index.to_list(), :]
alt_df = alt_df.loc[phenotype_df.index.to_list(), :]

# filter by gene list
if args.gene_list is not None:
    filename, genecol = args.gene_list.split(':')
    genelist_df = pd.read_csv(filename, sep='\t', compression='gzip', header=0)
    genelist_df = genelist_df[genecol].to_list()
    phenotype_df, ref_df, alt_df, phenotype_pos_df = filter_by_gene_list(genelist_df, phenotype_df, ref_df, alt_df, phenotype_pos_df)

# load covariates
logging.info('Load covariates')
covariates_df = pd.read_csv(covar_file, sep = '\t', index_col = 0, compression = 'gzip').T
covariates_df = covariates_df.loc[phenotype_df.columns.to_list(), :]

# run mixqtl
logging.info('Run mixQTL')
ix = phenotype_pos_df[phenotype_pos_df['chr']==args.chr].index
mixqtl.map_nominal(hap1_df, hap2_df, variant_df, 
                   log_counts_df.loc[ix], phenotype_df.loc[ix], ref_df.loc[ix], alt_df.loc[ix],
                   phenotype_pos_df.loc[ix], covariates_df, output_prefix,
                   output_dir=outdir, verbose=True,
                   **param_mixqtl)

