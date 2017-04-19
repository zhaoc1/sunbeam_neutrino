# sunbeam_neutrino
Downstream analysis after using sunbeam pipeline.

### Environment setup

```
bash install.sh

```

### Development

To updated the requirements file (after installing some new package):
```
conda list --name sunbeam --explicit > requirements.txt
```

### Functional testing

```
cd sunbeam_neutrino
bash tests/test.sh /path/to/test/dir

```

### Run on respublica

May need to unset PYTHONHOME for first time users.

```
unset PYTHONHOME
unset PYTHONPATH
source activate sunbeam

snakemake -j 40 --configfile config_X.yml --cluster-config configs/cluster.json -w 90 --notemp -p -c "qsub -cwd -r n -V -l h_vmem={cluster.h_vmem} -l mem_free={cluster.mem_free} -pe smp {threads}"

```
