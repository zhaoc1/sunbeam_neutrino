# sunbeam_addon
Downstream analysis after using sunbeam pipeline.

### Environment setup
Do this once:
```
sourcee activate sunbeam

# conda only keep track of the packages it installed. 
pip install git+https://github.com/zhaoc1/PathwayAbundanceFinder.git

snakemake
```

### Development

To updated the requirements file (after installing some new package):
```
conda list --name sunbeam --explicit > requirements.txt
```

### Run on respublica

May need to unset PYTHONHOME for first time users.

```
unset PYTHONHOME
unset PYTHONPATH
source activate sunbeam

snakemake -j 8 --cluster-config configs/cluster.json -p -c "qsub -cwd -r n -V -l h_vmem={cluster.h_vmem} -l mem_free={cluster.mem_free} -pe smp {threads}"

```
