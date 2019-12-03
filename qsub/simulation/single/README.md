## Simulation setup (parameter YAML)

We vary sample size and mean of theta while keeping SD of theta as a quarter of mean theta. 

All other parameters are shared across all simulations.
So that these set of parameters are in one flie `param_in_common.yaml`

In each run, we specify the following parameters, *e.g.*:

```
Nsample: 300
theta_mu: 1e-5
theta_sd: 5e-6
```

And save the file with full parameters as `configs/param_samplesize[Nsample]_x_theta[theta_mu].yaml`

## Job configfile

```
M: 200
parameter_file:
  name: 'samplesize[Nsample]_x_theta[theta_mu]'
  path: '../../qsub/simulation/single/configs/param_samplesize[Nsample]_x_theta[theta_mu].yaml'
```

It should be generated for each submission in `configs/config_samplesize[Nsample]_x_theta[theta_mu].yaml`

## Implementation 

All these steps are realized in `submit.sh` along with a light `qsub` file `run.qsub`