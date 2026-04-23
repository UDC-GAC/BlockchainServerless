scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function generate_load {
  export exptime=0
  gen_load1
  wait_experiment "1.40"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/genomics.sh

export START_CREDIT=20
export MAX_DEBT="-3"
export POLICY="greedy"
export TIMEOUT=120

export exp_name="genomics_greedy_1"
setup_exp
run_simple_exp
sleep 120

export exp_name="genomics_greedy_2"
setup_exp
run_simple_exp
sleep 120

export exp_name="genomics_greedy_3"
setup_exp
run_simple_exp
sleep 120

export exp_name="genomics_greedy_4"
setup_exp
run_simple_exp
sleep 120