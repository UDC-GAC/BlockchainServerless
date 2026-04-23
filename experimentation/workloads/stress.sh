scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
  myecho "This load does not load anything in staging dir"
}

#function generate_load {  
  #myecho "Submitting 5 tasks"
  #LD="1-150" && touch $LD.txt && mycopy $LD.txt "input"
  #LD="2-100" && touch $LD.txt && mycopy $LD.txt "input"
  #LD="3-250" && touch $LD.txt && mycopy $LD.txt "input"
  #LD="2-200" && touch $LD.txt && mycopy $LD.txt "input"
  #LD="1-400" && touch $LD.txt && mycopy $LD.txt "input"
  #myecho "Wait until these tasks finish"
  #sleep 1100
  
  #myecho "Leaving some space between tasks and sending credit"
  #sleep 100
  #send_credit 2
  #sleep 100
  
  #myecho "Submitting 2 more tasks"
  #LD="3-100" && touch $LD.txt && mycopy $LD.txt "input"
  #LD="1-200" && touch $LD.txt && mycopy $LD.txt "input"
  #LD="2-100" && touch $LD.txt && mycopy $LD.txt "input"
  #LD="1-300" && touch $LD.txt && mycopy $LD.txt "input"
  #myecho "Wait until these tasks finish"
  #sleep 700
  
  #myecho "Waiting until timeout now"
  #sleep ${TIMEOUT}
#}


function generate_load {  
  myecho "Submitting a very long task"
  LD="3-1000" && touch $LD.txt && mycopy $LD.txt "input"
  myecho "Wait until the task finishes"
  sleep 1000
  
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
export TIMEOUT=60

export MIN_BALANCE="0"
export MAX_DEBT="-0.5"
export START_CREDIT=4
export POLICY="greedy"
export exp_name="stress_3"
#setup_exp
#run_simple_exp


export MIN_BALANCE="0"
export MAX_DEBT="-0.5"
export START_CREDIT=1
export POLICY="greedy"
export exp_name="stress_4"
#setup_exp
#run_simple_exp

export MIN_BALANCE="0.5"
export MAX_DEBT="-0.5"
export START_CREDIT=2
export POLICY="greedy"
export exp_name="stress_4"
setup_exp
run_simple_exp
