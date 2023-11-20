scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function phase {
  send_credit $2
  export test_name="$1"
  signal_test "start"
  myecho "Going to wait for $3"
  sleep "$3"
  signal_test "end"
}

function generate_load {
  export exptime=0

  gen_load1
  myecho "Sending now some credit to compute some tasks"
  wait_experiment "1.25"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/genomics.sh

export START_CREDIT=20

export exp_name="$(date "+%m_%d_%H:%M")_genomics_greedy"

setup_exp
run_simple_exp
