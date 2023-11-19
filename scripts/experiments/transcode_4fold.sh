scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")


function generate_load {
  export exptime=0
  gen_load1
  myecho "Waiting 20 seconds to allow container to start"
  sleep 20
  wait_experiment "1.15"

  export exptime=0
  gen_load2
  wait_experiment "1.15"

  export exptime=0
  gen_load3
  wait_experiment "1.15"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/transcode.sh

export START_CREDIT=5
export MAX_DEBT="-0.5"
export POLICY="greedy"

export exp_name="$(date "+%m_%d_%H:%M")_4fold"

setup_exp
run_4_fold_exp
