scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
#  mc cp STORE/data/metagenomics/input/Homo_sapiens_assembly38.hss myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/Homo_sapiens_assembly38.fasta myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/Homo_sapiens_assembly38.dict myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/Homo_sapiens_assembly38.fasta.img myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/RefSeq-release93.catalog.gz myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/taxdump.tar.gz myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/sample_processed/13566_5_232_aligned.bam myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/sample_processed/13566_5_232_aligned.bam.sbi myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/sample_processed/13566_5_232.bam myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/sample_processed/13566_5_232_paired.bam myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/sample_processed/13566_5_232_paired.bam.sbi myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/sample_processed/13566_5_232_unpaired.bam myminio/genomics/staging/
#  mc cp STORE/data/metagenomics/input/sample_processed/13566_5_232_unpaired.bam.sbi myminio/genomics/staging/
  echo ""
}

export exptime=0
function sumtime {
  declare -A serv
  serv["bacteria.1001.1.genomic.fna.gz"]="1332"
  serv["bacteria.1002.1.genomic.fna.gz"]="724"
  serv["bacteria.1003.1.genomic.fna.gz"]="1407"
  serv["bacteria.1004.1.genomic.fna.gz"]="1190"

  declare -A noserv
  noserv["bacteria.1001.1.genomic.fna.gz"]="1252"
  noserv["bacteria.1002.1.genomic.fna.gz"]="610"
  noserv["bacteria.1003.1.genomic.fna.gz"]="1326"
  noserv["bacteria.1004.1.genomic.fna.gz"]="1046"

  if [[ ${test_type} == "serv" ]];
  then
    exptime=$(echo "${exptime} + ${serv["$1"]}" | bc)
  elif [[ ${test_type} == "noserv" ]]; then
    exptime=$(echo "${exptime} + ${noserv["$1"]}" | bc)
  fi
}

function generate_load_sample {
  mycopy STORE/data/metagenomics/input/$1 "input"
  sumtime "$1"
}

function configure_rules {
  myecho "Configuring Rules"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 250
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown down 6 # default is 6
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/set_event_timeout.sh 80 # default is 80
}

function gen_load1 {
  generate_load_sample "bacteria.1001.1.genomic.fna.gz"
  generate_load_sample "bacteria.1002.1.genomic.fna.gz"
  generate_load_sample "bacteria.1003.1.genomic.fna.gz"
  #generate_load_sample "bacteria.1004.1.genomic.fna.gz"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/common.sh

export CONT_MAX_CPU=1200
export CONT_BOUNDARY_CPU=75
export LOAD_NAME="genomics"
export LOAD_BUCKET="myminio/${LOAD_NAME}"
export TIMEOUT=25
export MIN_BALANCE=1
export MAX_DEBT="-1"
export START_CREDIT=30
export POLICY="greedy"