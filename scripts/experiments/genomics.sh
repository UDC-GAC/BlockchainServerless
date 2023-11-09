scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
#  mycopy STORE/data/metagenomics/input/Homo_sapiens_assembly38.hss "staging"
#  mycopy STORE/data/metagenomics/input/Homo_sapiens_assembly38.fasta "staging"
#  mycopy STORE/data/metagenomics/input/Homo_sapiens_assembly38.dict "staging"
#  mycopy STORE/data/metagenomics/input/Homo_sapiens_assembly38.fasta.img "staging"
#  mycopy STORE/data/metagenomics/input/RefSeq-release93.catalog.gz "staging"
#  mycopy STORE/data/metagenomics/input/13566_5_232.bam "staging"
#  mycopy STORE/data/metagenomics/input/taxdump.tar.gz "staging"
nop
}

function generate_load {
  mycopy STORE/data/metagenomics/input/bacteria.1001.1.genomic.fna.gz "input"
}

export -f generate_load
export -f load_staging_data

export LOAD_NAME="genomics"
export TIMEOUT=45
export MIN_BALANCE=1
export MAX_DEBT="-1"
export START_CREDIT=40

bash ${scriptDir}/common.sh