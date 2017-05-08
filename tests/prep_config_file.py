import sys
import yaml
import argparse
from pathlib import Path

def main():

    parser = argparse.ArgumentParser(description="Modifies test config with testing values")
    parser.add_argument(
        "--config", help="Test config file", type=argparse.FileType("r"),
        default=sys.stdin)

    args = parser.parse_args()
    config = yaml.load(args.config)

    config['all']['filename_fmt'] = "PCMP_{sample}_{rp}.fastq"
    config['qc']['human_index_fp'] = "indexes/human.fasta"
    config['qc']['phix_index_fp'] = "indexes/phix174.fasta"
    config['classify']['kraken_db_fp'] = "mindb"
    config['assembly']['cap3_fp'] = "local/CAP3"
    config['blastdbs']['root_fp'] = "local/blast"
    config['blastdbs']['nucleotide']['bacteria'] = 'bacteria.fa'
#    config['blastdbs']['nucleotide']['card'] = "card/nucleotide_fasta_protein_homolog_model.fasta"
#    config['blastdbs']['protein']['card'] = "card/nucleotide_fasta_protein_homolog_model.fasta"
    config['mapping']['rapsearch_fp'] = "local/RAPSearch2/bin"
    config['mapping']['kegg_fp'] = "indexes/kegg"
    config['mapping']['kegg_idx_fp'] = "indexes/keggRAP"
    config['mapping']['kegg_to_ko_fp'] = "indexes/kegg2ko"
    config['mapping']['genomes_fp'] = "indexes/fungalIndexes"
    config['mapping']['bileacid_fp'] = "indexes/bileAcidsIndexes"
    config['mapping']['Rscript_fp'] = "local/bin"
    config['mapping']['igv_fp'] = "local/IGV/igv.sh"
    config['classify']['metaphlan_fp'] = "local/biobakery-metaphlan2-40d1bf693089"
    config['classify']['mpa_pkl_fp'] = "local/biobakery-metaphlan2-40d1bf693089/db_v20/mpa_v20_m200.pkl"
    config['classify']['bt2_db_fp'] = "local/biobakery-metaphlan2-40d1bf693089/db_v20/mpa_v20_m200"

    sys.stdout.write(yaml.dump(config))

if __name__ == "__main__":
    main()
