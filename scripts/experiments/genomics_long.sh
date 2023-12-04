scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function generate_load {
  gen_load_long
  sleep 7200
  sleep 1200
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/genomics.sh

export START_CREDIT=50
export MIN_BALANCE=8
export MAX_DEBT="-3" # Not actually used
export POLICY="conservative"
export TIMEOUT=120

export exp_name="genomics_long"
setup_exp
run_simple_exp
sleep 120