import argparse
parser = argparse.ArgumentParser(prog='prepare_genotypes.py', description='''
    Prepare the genotypes in parquet format (split by chromosome) for py-mixqtl run
''')
parser.add_argument('--genotype-input', help='''
    VCF format (should have tbi files along with it)
''')
parser.add_argument('--genotype-out-prefix', help='''
    prefix of the output 
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
import gzip
import os

# output dir
outdir = args.outdir
if not (os.path.exists(outdir) and os.path.isdir(outdir)):
    os.mkdir(outdir)
# inputs
genotype_input = args.genotype_input
genotype_out_prefix = args.genotype_out_prefix

# process by chromosome
gt_dict = {'0':np.int8(0), '1':np.int8(1), '.':np.int8(-1)}
chromosomes = [ str(i) in range(1, 23) ]
chromosomes.append('X')
for chr in chromosomes:
    logging.info(f'Processing chr{chr}')
    vcf = f'{outdir}/{genotype_out_prefix}.chr{chr}'
    # get header
    cmd = f'zcat {genotype_input} | head -n 3388 > {vcf}'
    os.system(cmd)
    # extract the chromosome
    cmd = f'tabix {genotype_input} chr{chr} >> {vcf}'
    os.system(cmd)
    logging.info(f'--> VCF extraction finished: {vcf}')
    
    # go into the extracted file
    with open(vcf, 'rt') as f:
        variant_ids = []
        hap1 = []
        hap2 = []
        for line in f:
            if line.startswith('##'):
                continue
            break
        sample_ids = line.strip().split('\t')[9:]

        # read first line, parse field
        line = f.readline().strip().split('\t')
        gt_ix = line[8].split(':').index('GT')
        variant_ids.append(line[2])
        d = [i.split(':')[gt_ix].split('|') for i in line[9:]]
        hap1.append(np.array([gt_dict[i[0]] for i in d]))
        hap2.append(np.array([gt_dict[i[1]] for i in d]))

        for k,line in enumerate(f,2):
            line = line.strip().split('\t')
            variant_ids.append(line[2])
            d = [i.split(':')[gt_ix].split('|') for i in line[9:]]
            hap1.append(np.array([gt_dict[i[0]] for i in d]))
            hap2.append(np.array([gt_dict[i[1]] for i in d]))

            if np.mod(k,1000)==0:
                print('\rVariants parsed: {}'.format(k), end='')
    logging.info(f'Finished scanning chr{chr}')
    hap1_df = pd.DataFrame(
        np.array(hap1), 
        index=variant_ids, 
        columns=sample_ids
    )
    hap1_df.to_parquet(f'{outdir}/{genotype_out_prefix}.chr{chr}.hap1.parquet')

    hap2_df = pd.DataFrame(
        np.array(hap2), 
        index=variant_ids, 
        columns=sample_ids
    )
    hap2_df.to_parquet(f'{outdir}/{genotype_out_prefix}.chr{chr}.hap2.parquet')
            
    
    
