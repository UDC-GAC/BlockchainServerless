scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
  myecho "This load does not load anything in staging dir"
}


function generate_load {
  mc cp vina/1iep.tar.gz "myminio/vina/input/1iep.tar.gz"
  myecho "Waiting 20 seconds to allow container to start"
  sleep 20
  myecho "Waiting for the load to finish"
  sleep 400
}

function configure_rules {
  echo "Configuring Rules"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 200
}

export -f generate_load
export -f load_staging_data
export -f configure_rules

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/common.sh

export CONT_MAX_CPU=600
export CONT_BOUNDARY_CPU=50
export LOAD_NAME="vina"
export LOAD_BUCKET="myminio/${LOAD_NAME}"
export TIMEOUT=10

export MIN_BALANCE="0"
export MAX_DEBT="-0.5"
export START_CREDIT=2
export POLICY="greedy"
export exp_name="check_task_vina"
setup_exp
run_simple_exp
