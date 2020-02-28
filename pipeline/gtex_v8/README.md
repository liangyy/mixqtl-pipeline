# Data

We used GTEx V8 data. 
Some of the data is protected so that they are not publicly available.
To obtain access to protected data, please refer to [this link](https://gtexportal.org/home/protectedDataAccess).

* Allele Specific Expression (ASE) tables: `GTEx_Analysis_v8_ASE_WASP_counts_by_subject/*.v8.wasp_corrected.ase_table.tsv.gz`.
* Gene read counts: `GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_reads.gct.gz`.
* Genotype Calls: `GTEx_Analysis_2017-06-05_v8_WholeGenomeSeq_838Indiv_Analysis_Freeze.SHAPEIT2_phased.MAF01.vcf.gz`.

The followings are **Only used for comparing to vanilla method)**:

* Normalized expression matrix (Whole blood) : `GTEx_Analysis_v8_eQTL_expression_matrices/Whole_Blood.v8.normalized_expression.bed.gz`.
* Covariates for normalized expression matrix (Whole blood): `GTEx_Analysis_v8_eQTL_covariates/Whole_Blood.v8.covariates.txt`.

# Preprocessing and formatting

For total count, we run:
 
* Format the matrix. (`expression.snmk`)
* PEER factor analysis to obtain covariates for mixQTL. (`get_peer_factor.snmk`)

For ASE count, we do:

* Merge per-individual WASP ASE count table into a gene-level ASE count matrix with individuals in rows and genes in columns (for each of the two haplotypes). (`wasp2matrix.snmk`)
* Format the matrix. (`expression.snmk`)

For genotype/haplotype, we collect cis-window for each gene and save it as `txt.gz`. (`genotype.snmk`)

# Actual runs

TODO

