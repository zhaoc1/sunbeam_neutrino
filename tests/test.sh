#!/bin/bash
# Bash flags: Do not commit to repo with these commented out
set -e # Stop on errors

# Ensure we can activate the environment
export PATH=$PATH:$HOME/miniconda3/bin

# Set up paths
ROOT=`pwd`

if [ $# -ne 1 ]; then
    echo "Write test output to temp file"
    TEMPDIR=`mktemp -d`
else
    TEMPDIR="$1"
fi

# Activate the sunbeam environment
source activate sunbeam_neutrino
command -v snakemake

mkdir -p $TEMPDIR/data_files

function cleanup {
    # Remove temporary directory if it exists
    # (must be careful with rm -rf and variables)
    [ -z ${TEMPDIR+x} ] || rm -rf "$TEMPDIR"
}

# Calls cleanup when the script exits
#trap cleanup EXIT

pushd tests
# Copy data into the temporary directory
cp -r ../local $TEMPDIR/local
cp -r indexes $TEMPDIR
cp -r raw $TEMPDIR
cp -r truncated_taxonomy $TEMPDIR

python generate_dummy_data.py $TEMPDIR

# Create a version of the config file customized for this tempdir
CONFIG_FP=$TEMPDIR/local/config_default.yml
sunbeam_init $TEMPDIR --template $CONFIG_FP | python prep_config_file.py  > $TEMPDIR/tmp_config.yml

popd

pushd $TEMPDIR
# Build fake kraken data
kraken-build --db mindb --add-to-library raw/GCF_Bfragilis_10k_genomic.fna
kraken-build --db mindb --add-to-library raw/GCF_Ecoli_10k_genomic.fna
mv truncated_taxonomy mindb/taxonomy
kraken-build --db mindb --build --kmer-len 16 --minimizer-len 1
kraken-build --db mindb --clean

# Build fake blast database
mkdir -p local/blast
cat raw/*.fna > local/blast/bacteria.fa
cp -r indexes/card local/blast
makeblastdb -dbtype nucl -in local/blast/bacteria.fa
#makeblastdb -dbtype nucl -in local/blast/card/nucleotide_fasta_protein_homolog_model.fasta
makeblastdb -dbtype prot -in local/blast/card/protein_fasta_protein_homolog_model.fasta
popd

# Running snakemake
echo "Now testing snakemake: "
snakemake --configfile=$TEMPDIR/tmp_config.yml --snakefile ../sunbeam/Snakefile
snakemake --configfile=$TEMPDIR/tmp_config.yml --snakefile ../sunbeam/Snakefile clean_assembly
snakemake --configfile=$TEMPDIR/tmp_config.yml -p

echo "Now testing for metaphlan"
snakemake --configfile=$TEMPDIR/tmp_config.yml all_metaphlan -p

# Check contents
echo "Now checking whether we hit the expected genome:"
grep 'NC_006347.1' $TEMPDIR/sunbeam_output/annotation/summary/dummybfragilis.tsv

# Check targets
python tests/find_targets.py --prefix $TEMPDIR/sunbeam_output tests/targets.txt 
