import argparse
parser = argparse.ArgumentParser(prog='prepare_matrices.py', description='''
    Prepare the bundle of input matrices for py-mixqtl run
''')
parser.add_argument('--ase-matrix', help='''
    allele-specific count matrix
''')
parser.add_argument('--trc-matrix', help='''
    total read count matrix
''')
parser.add_argument('--libsize', help='''
    library size
''')
parser.add_argument('--covariate-matrix', help='''
    covariate matrix
''')
parser.add_argument('--gene-annotation', help='''
    gene annotation so that we can 
    annotate with the genomic position. 
''')
parser.add_argument('--outdir', help='''
    directory of output (if not exists, it will be created)
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


import pandas as pd
import numpy as np
import gzip, os

# outputs
outdir = args.outdir
if not (os.path.exists(outdir) and os.path.isdir(outdir)):
    os.mkdir(outdir)
trc_out = 'total_count.bed.gz'
asc1_out = 'allele_specific_count.hap1.txt.gz'
asc2_out = 'allele_specific_count.hap2.txt.gz'
intermediate_out = 'tempo-gtex_v8_library_size.txt'
libsize_out = 'gtex_v8_library_size.txt.gz'
covar_out = 'covariates.txt.gz'

# ASE counts
logging.info('Processing ASE counts')
df_ase = pd.read_csv(args.ase_matrix, header=0, compression='gzip', sep='\t')
df_ase = df_ase.set_index('GENE_ID')
a1_ase = df_ase.drop(df_ase.columns[df_ase.shape[1] - 1], axis = 1).applymap(lambda x: int(x.split('|')[0]))
a2_ase = df_ase.drop(df_ase.columns[df_ase.shape[1] - 1], axis = 1).applymap(lambda x: int(x.split('|')[1]))

# Total counts
logging.info('Processing total counts')
df_trc = pd.read_csv(args.trc_matrix, header = 0, compression = 'gzip', sep = '\t')
df_trc = df_trc.set_index('Name')
df_trc = df_trc.drop(df_trc.columns[df_trc.shape[1] - 1], axis = 1).drop('Description', axis = 1)
df_trc = df_trc[a1_ase.columns]
df_trc = df_trc.reset_index()
df_annot = pd.read_csv(args.gene_annotation, header = 0, sep = '\t')
# add the gene id without dot 
df_trc['gene_trimmed'] = df_trc['Name'].apply(lambda x: x.split('.')[0])
# add tss
df_annot.loc[:, 'tss'] = df_annot.apply(lambda x: x.start if x.strand == '+' else x.end, axis = 1).to_list()
df_trc = df_trc.set_index('gene_trimmed').join(df_annot.loc[:, ['gene_id', 'tss', 'chromosome']].set_index('gene_id'))
# get the columns needed for bed file
df_trc = df_trc.rename(columns = {'chromosome': '#chr'})
df_trc['gene_id'] = df_trc.index.to_list()
l = df_trc.columns.to_list()
l.remove('tss')
l.remove('gene_id')
l.remove('Name')
l.remove('#chr')
df_trc['start'] = df_trc['tss'] - 1
df_trc['end'] = df_trc['tss']
df_trc = df_trc.loc[:, ['#chr', 'start', 'end', 'gene_id'] + l ]
    
# Library size
logging.info('Processing library size')
libsize_input = args.libsize
cmd = f'cat {libsize_input} | cut -f1,45 > {outdir}/{intermediate_out}'
os.system(cmd)
df_lib = pd.read_csv(f'{outdir}/{intermediate_out}', header = 0, sep = '\t')
df_lib = df_lib.set_index('SAMPID')
df_lib = df_lib.loc[df_trc.columns.to_list()[4:]]

# Covariates
logging.info('Processing covariates')
covariate_matrix = args.covariate_matrix
cmd = f'cat {covariate_matrix} | gzip > {outdir}/{covar_out}'
os.system(cmd)

# Saving results
logging.info('Saving results')
a1_ase.columns = a1_ase.columns.map(lambda x: '-'.join(x.split('-')[:2]))
a2_ase.columns = a2_ase.columns.map(lambda x: '-'.join(x.split('-')[:2]))
a1_ase.to_csv(f'{outdir}/{asc1_out}', sep = '\t', compression = 'gzip')
a2_ase.to_csv(f'{outdir}/{asc2_out}', sep = '\t', compression = 'gzip')
df_trc.columns = df_trc.columns.map(lambda x: '-'.join(x.split('-')[:2]))
df_trc.to_csv(f'{outdir}/{trc_out}', index = None, sep = '\t', compression = 'gzip')
df_lib.index = df_lib.index.map(lambda x: '-'.join(x.split('-')[:2]))
df_lib.to_csv(f'{outdir}/{libsize_out}', sep = '\t', compression = 'gzip')
