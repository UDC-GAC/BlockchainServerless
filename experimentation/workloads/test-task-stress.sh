scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
  myecho "This load does not load anything in staging dir"
}

function generate_load {  
  myecho "Submitting a short task as a test that everything works"
  NUM_CORES="2"
  TASK_LENGTH="100"
  myecho "This task stresses cores for seconds"
  LD="${NUM_CORES}-${TASK_LENGTH}" && touch $LD.txt && mycopy $LD.txt "input"
  myecho "Wait ${TASK_LENGTH} seconds until the task finishes"
  sleep ${TASK_LENGTH}
  myecho "Waiting until timeout now"
  sleep ${TIMEOUT}
}

function configure_rules {
  echo "Configuring Rules"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 100
}

export -f generate_load
export -f load_staging_data
export -f configure_rules

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/common.sh

export CONT_MAX_CPU=400
export CONT_BOUNDARY_CPU=25
export LOAD_NAME="stress"
export LOAD_BUCKET="myminio/${LOAD_NAME}"
export TIMEOUT=30

export MIN_BALANCE="0"
export MAX_DEBT="-0.5"
export START_CREDIT=1
export POLICY="greedy"
export exp_name="check_system_stress"
setup_exp
run_simple_exp
