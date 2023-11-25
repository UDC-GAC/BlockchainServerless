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
export MAX_DEBT="-3" # Not actually used
export POLICY="conservative"
export TIMEOUT=120

export exp_name="genomics_conservative_1"
setup_exp
run_simple_exp
sleep 120

#export exp_name="genomics_conservative_2"
#setup_exp
#run_simple_exp
#sleep 120
#
#export exp_name="genomics_conservative_3"
#setup_exp
#run_simple_exp
#sleep 120