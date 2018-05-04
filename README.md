# sunbeam_neutrino
Downstream analysis after using sunbeam pipeline.

### Environment setup

```
bash install.sh
```

### Development

To updated the requirements file (after installing some new package):
```
conda list --name sunbeam_neutrino --explicit > requirements.txt
```

### Functional testing

```
cd sunbeam_neutrino
bash tests/test.sh /path/to/test/dir
```

### Run on respublica

```
unset PYTHONHOME
unset PYTHONPATH
source activate sunbeam

snakemake -j XX --configfile config_neutrino.yml --cluster-config configs/cluster.json -w 90 --notemp -p \
     -c "qsub -cwd -r n -V -l h_vmem={cluster.h_vmem} -l m_mem_free={cluster.m_mem_free} -pe smp {threads}"
```
