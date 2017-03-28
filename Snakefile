#
# Sunbeam Addon Rules
#
# Author: Chunyu Zhao <zhaocy.dut@gmail.com>
# Created: 2017-03-05
#

import re
import sys
import yaml
import configparser
from pprint import pprint
from pathlib import Path

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
MAPPING_FP = output_subdir(Cfg, 'mapping')

# ---- Targets rules
include: "rules/targets/targets.rules"

# ---- Antibiotic resistance gene rules
#include: "rules/abx/abx_genes.rules"

# ---- Mapping rules
include: "rules/mapping/bowtie.rules"
include: "rules/mapping/kegg.rules"
#include: "rules/mapping/snap.rules"

# ---- Rule all: run all targets
rule all:
    input: TARGET_ALL

rule samples:
    run:
        print("Samples found:")
        pprint(sorted(list(Samples.keys())))

