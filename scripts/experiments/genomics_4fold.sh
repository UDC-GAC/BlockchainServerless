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
export MAX_DEBT="-3"
export POLICY="conservative"
export TIMEOUT=120

export exp_name="genomics_4fold_1"
setup_exp
run_4_fold_exp
sleep 120

export exp_name="genomics_4fold_2"
setup_exp
run_4_fold_exp
sleep 120

export exp_name="genomics_4fold_3"
setup_exp
run_4_fold_exp
sleep 120

export exp_name="genomics_4fold_4"
setup_exp
run_4_fold_exp
sleep 120
