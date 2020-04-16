import pandas as pd
import numpy as np
datadir = '/vol/bmd/yanyul/UKB/GTExV8'
df1 = pd.read_csv(f'{datadir}/Whole_Blood.v8.egenes.txt.gz', compression='gzip', sep='\t', header=0)
df2 = pd.read_csv(f'{datadir}/annotations_gencode_v26.tsv', sep='\t', header=0)
df1['gene_id'] = df1['gene_id'].map(lambda x: x.split('.')[0])
merge = pd.merge(df2, df1, left_on='gene_id', right_on='gene_id', how='left', suffixes=('', '_new'))
merge['start'] = merge[['start', 'gene_start']].apply(lambda x: int(x[0]) if pd.isna(x[1]) else int(x[1]), axis=1)
merge['end'] = merge[['end', 'gene_end']].apply(lambda x: int(x[0]) if pd.isna(x[1]) else int(x[1]), axis=1)
merge['strand'] = merge[['strand', 'strand_new']].apply(lambda x: x[0] if pd.isna(x[1]) else x[1], axis=1)
merge[df2.columns].to_csv(f'{datadir}/annotations_gencode_v26_fixed_some_from_gtex_v8_egene.tsv', sep='\t', index=False)
