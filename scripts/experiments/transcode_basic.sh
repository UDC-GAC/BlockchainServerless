function passtime {
  myecho "Simulating some wait time"
  sleep $1
}

function generate_load {

  export exptime=0
  export test_name="1"
  signal_test "start"
  send_credit 4
  gen_load1
  myecho "Waiting 20 seconds to allow container to start"
  sleep 20
  wait_experiment "1.15"
  passtime 100
  signal_test "end"

  export exptime=0
  export test_name="2"
  signal_test "start"
  send_credit 2
  gen_load2
  wait_experiment "1.15"
  passtime 200
  signal_test "end"

  export exptime=0
  export test_name="3"
  signal_test "start"
  send_credit 3
  gen_load3
  wait_experiment "1.15"
  passtime 100
  signal_test "end"

  export exptime=0
  export test_name="4"
  signal_test "start"
  send_credit 1
  gen_load4
  wait_experiment "1.15"
  signal_test "end"

  export exptime=0
  export test_name="5"
  signal_test "start"
  send_credit 1
  gen_load5
  wait_experiment "1.15"
  signal_test "end"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/transcode.sh
export TIMEOUT=250
# $(date "+%m_%d_%H:%M")_

export exp_name="transcode_basic_4"
setup_exp
run_simple_exp
