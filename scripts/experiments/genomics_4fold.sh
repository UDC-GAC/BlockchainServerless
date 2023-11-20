scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function generate_load {
  export exptime=0
  gen_load1
  wait_experiment "1.25"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/genomics.sh

export START_CREDIT=20
export MIN_BALANCE=8
export MAX_DEBT="-1"
export POLICY="conservative"

export exp_name="$(date "+%m_%d_%H:%M")_genomics_4fold"

setup_exp
run_4_fold_exp
