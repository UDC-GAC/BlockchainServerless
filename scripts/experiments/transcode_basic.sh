function passtime {
  myecho "Simulating some wait time"
  sleep $1
}

function generate_load {

  export exptime=0
  send_credit 4
  gen_load1
  myecho "Waiting 20 seconds to allow container to start"
  sleep 20
  wait_experiment "1.15"
  passtime 60

  export exptime=0
  send_credit 2
  gen_load2
  wait_experiment "1.15"
  passtime 280

  export exptime=0
  send_credit "1.5"
  gen_load3
  wait_experiment "0.6"
  send_credit "1.5"
  wait_experiment "0.55"
  passtime 60

  export exptime=0
  send_credit 1
  gen_load4
  wait_experiment "0.6"

  export exptime=0
  send_credit "1"
  gen_load5
  wait_experiment "3"
}

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/transcode.sh
export TIMEOUT=180

export exp_name="transcode_basic_1"
setup_exp
run_simple_exp
sleep 120

export exp_name="transcode_basic_2"
setup_exp
run_simple_exp
sleep 120

export exp_name="transcode_basic_3"
setup_exp
run_simple_exp
sleep 120

export exp_name="transcode_basic_4"
setup_exp
run_simple_exp
sleep 120

