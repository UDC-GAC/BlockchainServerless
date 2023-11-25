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
  gen_load2
  gen_load3
  gen_load4
  gen_load5

  #phase 1 15 "1.3"

#  myecho "Wait a little bit, tasks will be queued waiting for credit"
#  sleep 120
  myecho "Sending now some credit to compute some tasks"
  phase 1 4 1750
  #myecho "Credit should be now between 0 and 2"
  #myecho "Sending now some more credit to compute some tasks"
  #phase 2 0 750
  #myecho "Credit should be now close to 0, and a task should have started"
  #phase 3 0 400
  #myecho "Some debt should have been generated up to now and restrictions should have been applied"
  #myecho "Sending more credit to pay the debt, which should be about 1 GRC, raise the restrictions and continue processing"
  phase 2 3 900
  myecho "The maximum debt should have been generated now, restrictions should have been applied, and the container/processing must have been stopped"
  myecho "Sending more credit to pay the debt, start a new container and finish the processing"
  phase 3 4 1000
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/transcode.sh

export TIMEOUT=300

export exp_name="transcode_greedy_1"
setup_exp
run_simple_exp
sleep 120

export exp_name="transcode_greedy_2"
setup_exp
run_simple_exp
sleep 120

export exp_name="transcode_greedy_3"
setup_exp
run_simple_exp
sleep 120
