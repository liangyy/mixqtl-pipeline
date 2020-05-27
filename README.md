# mixqtl-pipeline

## Overview

This repository reproduces the results for paper [link](https://www.biorxiv.org/content/10.1101/2020.04.22.050666v1)

It contains pipelines for

* Simulation
* mixQTL, mixPred, and mixFine runs on simulated data
* mixQTL and mixFine runs on GTEx V8 data (along with the pre-processing steps)

## Dependencies

It reproduces mixQTL results using `mixqtl` R package. To install, do

```
devtools::install_github('liangyy/mixqtl')
```

The pipeline is built using `snakemake`. 

## Directory structure

* `pipeline/`: pipelines in `snakemake` 
* `code/`: scripts for the pipeline
* `qsub/`: actual jobs running `pipeline`. It specifies all dependent files and parameters to reproduce the runs
* `analysis/`: analysis and summary report of the runs

