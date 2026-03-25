scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")


function generate_load {
  export exptime=0
  gen_load1
  gen_load2
  gen_load3
  myecho "Waiting 20 seconds to allow container to start"
  sleep 20
  wait_experiment "1.40"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/transcode.sh

export START_CREDIT="5.25"
export MAX_DEBT="-1"
export POLICY="greedy"

export exp_name="transcode_4fold_1"
setup_exp
run_4_fold_exp
sleep 120

export exp_name="transcode_4fold_2"
setup_exp
run_4_fold_exp
sleep 120

export exp_name="transcode_4fold_3"
setup_exp
run_4_fold_exp
sleep 120

export exp_name="transcode_4fold_4"
setup_exp
run_4_fold_exp
sleep 120