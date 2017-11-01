#
# Sunbeam_Neutrino
#
# Author: Chunyu Zhao <zhaocy.dut@gmail.com>
# Created: 2017-03-05
#

import re
import sys
import yaml
import configparser
from pprint import pprint
from pathlib import Path, PurePath

from snakemake.utils import update_config, listfiles
from snakemake.exceptions import WorkflowError

from sunbeamlib import build_sample_list
from sunbeamlib.config import *
from sunbeamlib.reports import *

if not config:
        raise SystemExit(
                "No config file specified. Run `sunbeam_init` to generate a "
                "config file, and specify with --configfile")


# ---- Setting up config files and samples
Cfg = check_config(config)
Blastdbs = process_databases(Cfg['blastdbs'])
Samples = build_sample_list(Cfg['all']['data_fp'], Cfg['all']['filename_fmt'], Cfg['all']['exclude'])


# ---- Change your workdir to output_fp
workdir: str(Cfg['all']['output_fp'])


# ---- Set up output paths for the various steps
QC_FP = output_subdir(Cfg, 'qc')
ASSEMBLY_FP = output_subdir(Cfg, 'assembly')
ANNOTATION_FP = output_subdir(Cfg, 'annotation')
CLASSIFY_FP = output_subdir(Cfg, 'classify')
MAPPING_FP = output_subdir(Cfg, 'mapping')


# ---- Fungal genome mapping
GENOME_DIR = Cfg['mapping']['genomes_fp']
GENOMES_KEY = [PurePath(f.name).stem for f in GENOME_DIR.glob('*.fasta')]
GENOMES_VAL = [str(GENOME_DIR) + '/' + g+'.fasta' for g in GENOMES_KEY]
GENOMES_DICT = dict(zip(GENOMES_KEY, GENOMES_VAL))

# ---- Bile acid read mapping
GENES_DIR = Cfg['mapping']['bileacid_fp']
GENES_KEY = [PurePath(f.name).stem for f in GENES_DIR.glob('*.fasta')]
GENES_VAL = [str(GENES_DIR) + '/' + g+'.fasta' for g in GENES_KEY]
GENES_DICT = dict(zip(GENES_KEY, GENES_VAL))

# ---- Blast DB mapping (antibiotics resistance and virus)
BLASTDB_DIR = Cfg['blastdbs']['root_fp']

BLASTDB_RAW_DICT_PROT= Blastdbs['prot']
BLASTDB_KEY_PROT = [PurePath(f.name).stem for f in BLASTDB_DIR.glob("*/*.fasta") if str(f) in BLASTDB_RAW_DICT_PROT.values()]
BLASTDB_DICT_PROT = dict(zip(BLASTDB_KEY_PROT, BLASTDB_RAW_DICT_PROT.values()))

BLASTDB_RAW_DICT_NUCL= Blastdbs['nucl']
BLASTDB_KEY_NUCL = [PurePath(f.name).stem for f in BLASTDB_DIR.glob("*/*.fasta") if str(f) in BLASTDB_RAW_DICT_NUCL.values()]
BLASTDB_DICT_NUCL = dict(zip(BLASTDB_KEY_NUCL, BLASTDB_RAW_DICT_NUCL.values()))

# ---- Diamond DB mapping (glycoside hydrolase)
DIAMOND_DIR = Cfg['mapping']['glyco_fp']
DIAMOND_KEY = [PurePath(f.name).stem for f in DIAMOND_DIR.glob('*.fasta')]
DIAMOND_VAL = [str(DIAMOND_DIR) + '/' + g +'.fasta' for g in DIAMOND_KEY]
DIAMOND_DICT = dict(zip(DIAMOND_KEY, DIAMOND_VAL))

# ---- Targets rules
include: "rules/targets/targets.rules"

# ---- Classifier rules
include: "rules/classify/metaphlan.rules"

# ---- Mapping rules
include: "rules/mapping/blast_db.rules"
include: "rules/mapping/fungi.rules"
include: "rules/mapping/kegg.rules"
include: "rules/mapping/bile_acid.rules"
include: "rules/mapping/abx_resist.rules"
include: "rules/mapping/glycoside.rules"
#include: "rules/mapping/contigs.rules"

# ---- Rule all: run all targets
rule all:
    input: TARGET_ALL

rule samples:
    run:
        print("Samples found:")
        pprint(sorted(list(Samples.keys())))

