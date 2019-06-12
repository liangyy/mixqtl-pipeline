# mixqtl-pipeline

## Overview

This repository contains pipeline to prepare input files for mixQTL

* Input: 
    - RNA-seq in BAM
    - Phased genotype in VCF
    - Other supporting files
* Output:
    - For each individual:
        + Total read count per gene (TRC)
        + Allele-specific read count per gene (ASE)
        + Number of heterozygous sites per gene (Heter)
    - PEER factors (individual-by-K) (PEER)

## Plan

* TRC: RNA-SeQC would be the main tool and I will follow [RNA-seq pipeline in GTEx](https://github.com/liangyy/gtex-pipeline/tree/master/rnaseq)
* ASE: phASER would be the main tool and I will follow [phASER tutorial](https://stephanecastel.wordpress.com/2017/02/15/how-to-generate-ase-data-with-phaser/)
* Heter: it would be one of the phASER output
* PEER: `peer` in R would be the main tool and I will follow [PEER factor calculation used in GTEx](https://github.com/liangyy/gtex-pipeline/blob/master/qtl/eqtl_peer_factors.wdl)
