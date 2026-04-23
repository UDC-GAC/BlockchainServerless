COMMON_SCRIPTS_PATH="BlockchainServerless/deployment/scripts/tasks"
GRIDCOIN_SCRIPTS_PATH="BlockchainServerless/deployment/scripts/gridcoin/"

function check_return_code201 {
  return_code="$http_code"
  if ! [[ ${return_code} =~ ^[0-9]+$ ]] || [[ "${return_code}" -ne "201" ]]; then
    myecho "There was an error with this request, printed next"
    myecho "${return_code}"
    myecho "Stopping"
    exit 1
  fi
}

function myecho {
  message="[$(date "+%H:%M")] $1"
  echo ${message} >>"${LOGFILE}" 2>&1
  echo ${message}
}

function set_user_policy {
  myecho "Setting user policy to ${POLICY}"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_policy_${POLICY}.sh user0)
  check_return_code201
}

function set_user_min_balance {
  myecho "Setting user min balance of ${MIN_BALANCE}"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_min_balance.sh user0 ${MIN_BALANCE})
  check_return_code201
}

function set_user_max_debt {
  myecho "Setting user max debt of ${MAX_DEBT}"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_max_debt.sh user0 ${MAX_DEBT})
  check_return_code201
}

function signal_test {
  myecho "Signaling experiment test ${1}"
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_test.py ${1} ${exp_name} ${test_name} --push --username root
}

function signal_exp {
  myecho "Signaling experiment ${1}"
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py ${1} ${exp_name} --push --username root
}

function set_serverless {
  myecho "Setting serverless to ${1}"
  apptainer exec instance://sc bash ${COMMON_SCRIPTS_PATH}/set-cont-guard.sh ${1}
}

function set_accounting {
  myecho "Setting accounting to ${1}"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting.sh user0 ${1})
  check_return_code201
}

function set_user_credit {
  myecho "Setting user credit"
  set_accounting "true"
  bash ${GRIDCOIN_SCRIPTS_PATH}/set_user_balance.sh ${START_CREDIT}
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_pending_zero.sh user0)
  check_return_code201
  sleep 15
  set_accounting "false"
}

function send_credit {
  myecho "User sends credit, $1 GRC"
  apptainer exec instance://grc bash ${GRIDCOIN_SCRIPTS_PATH}/gridcoin-run.sh move sink user0 $1
}

function wait_experiment {
  myecho "Experiment estimated time is ${exptime}"
  sleep_time=$(echo "${exptime} * $1" | bc)
  myecho "Going to wait for ${sleep_time} to leave some margin"
  sleep ${sleep_time}
}

function wait_container_timeout {
  myecho "Waiting container timeout (${TIMEOUT})"
  sleep $TIMEOUT
  sleep 10 # Plus some more just to be sure
}

function prepare_base_buckets {
  myecho "-------------------"
  myecho "Setting up basic buckets (utils, logs and staging)"
  {
    mc rm --force --recursive ${LOAD_BUCKET}/utils/
    mc rm --force --recursive ${LOAD_BUCKET}/logs/
    #mc rm --force --recursive ${LOAD_BUCKET}/staging/
    mc mb ${LOAD_BUCKET}/utils
    mc mb ${LOAD_BUCKET}/logs
    mc mb ${LOAD_BUCKET}/staging
  } >>${LOGFILE} 2>&1
  myecho "-------------------"
  myecho "Copying the 'process_task.sh' script for this load to the 'utils' bucket in '${LOAD_BUCKET}'"
  mc cp BlockchainServerless/usage/tasks/${LOAD_NAME}/process_task.sh ${LOAD_BUCKET}/utils/ >>${LOGFILE} 2>&1
  myecho "Copying the '${LOAD_NAME}.sif' container image for this load to the 'utils' bucket in '${LOAD_BUCKET}'"
  mc cp "${LOAD_NAME}.sif" ${LOAD_BUCKET}/utils/ >>${LOGFILE} 2>&1
  myecho "Copying the required data in staging, according to the load"
  load_staging_data
}

export countcopy=100 # Start with 100 to avoid incorrect ordering (0,1,10,11...,2,21..)

function mycopy {
  mc cp $1 "myminio/${LOAD_NAME}/$2/${countcopy}.$(basename $1)"
  countcopy=$(echo "${countcopy} + 1" | bc)
}

function empty_bucket {
  myecho "-------------------"
  myecho "Emptying buckets"
  {
    mc rm --force --recursive ${LOAD_BUCKET}/results/
    mc rm --force --recursive ${LOAD_BUCKET}/input/
    mc rm --force --recursive ${LOAD_BUCKET}/processing/
    mc rm --force --recursive ${LOAD_BUCKET}/output/
    mc rm --force --recursive ${LOAD_BUCKET}/logs/
    #mc rm --force --recursive ${LOAD_BUCKET}/staging/
    mc mb ${LOAD_BUCKET}/results
    mc mb ${LOAD_BUCKET}/input
    mc mb ${LOAD_BUCKET}/processing
    mc mb ${LOAD_BUCKET}/output
    mc mb ${LOAD_BUCKET}/logs
    #mc mb ${LOAD_BUCKET}/staging
  } >>${LOGFILE} 2>&1
  myecho "-------------------"
}

function dump_bucket {
  myecho "-------------------"
  myecho "--- << ${EXP_OUT_DIR}/${test_name}"
  myecho "Bucket content is: "
  mc ls --recursive ${LOAD_BUCKET}/ >>${LOGFILE} 2>&1
  mc cp --recursive ${LOAD_BUCKET}/logs ${EXP_OUT_DIR}/${test_name}/
  mc cp --recursive ${LOAD_BUCKET}/results ${EXP_OUT_DIR}/${test_name}/
  empty_bucket
  myecho "-------------------"
}

function set_timeout_container {
  myecho "Setting timeout of ${TIMEOUT}"
  echo ${TIMEOUT} >timeout.txt
  mc cp timeout.txt ${LOAD_BUCKET}/utils >>${LOGFILE} 2>&1
}

function set-cont-template-cpu-current-to-max {
  myecho "Setting the cpu 'current' to the maximum allowed in the container template"
  apptainer exec instance://sc bash ${COMMON_SCRIPTS_PATH}/set-cont-current-to-max.sh
}

function set-cont-template-cpu-current-to-halfmax {
  myecho "Setting the cpu 'current' to the half the maximum allowed in the container template"
  apptainer exec instance://sc bash ${COMMON_SCRIPTS_PATH}/set-cont-current-to-half-max.sh
}

function set-cont-template-cpu-max {
  myecho "Setting container template max cpu to ${CONT_MAX_CPU}"
  apptainer exec instance://sc bash ${COMMON_SCRIPTS_PATH}/set-cont-max.sh ${CONT_MAX_CPU}
}

function set-cont-template-cpu-boundary {
  myecho "Setting container template cpu boundary to ${CONT_BOUNDARY_CPU}"
  apptainer exec instance://sc bash ${COMMON_SCRIPTS_PATH}/set-cont-boundary.sh ${CONT_BOUNDARY_CPU}
}

function set_user_billing_type_current {
  myecho "Setting user billing type to use the 'current' cpu (classic non-serverless scenario)"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_billing_type.sh user0 current
}

function set_user_billing_type_used {
  myecho "Setting user billing type to use the 'used' cpu (serverless scenario)"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_billing_type.sh user0 used
}

function run_serv_acct {
  export test_name="1.serv_acct"
  export test_type="serv"
  myecho "Running test ${test_name}"
  set-cont-template-cpu-current-to-halfmax
  set_user_billing_type_used
  set_user_credit
  set_serverless "true"
  set_accounting "true"
  signal_test "start"
  generate_load
  set_serverless "false"
  set_accounting "false"
  signal_test "end"
  wait_container_timeout
  dump_bucket
}

function run_serv_noacct {
  export test_name="2.serv_noacct"
  export test_type="serv"
  myecho "Running test ${test_name}"
  set-cont-template-cpu-current-to-halfmax
  set_user_billing_type_used
  set_user_credit
  set_serverless "true"
  set_accounting "false"
  signal_test "start"
  generate_load
  set_serverless "false"
  signal_test "end"
  wait_container_timeout
  dump_bucket
}

function run_noserv_acct {
  export test_name="3.noserv_acct"
  export test_type="noserv"
  myecho "Running test ${test_name}"
  set-cont-template-cpu-current-to-max
  set_user_billing_type_current
  set_user_credit
  set_serverless "false"
  set_accounting "true"
  signal_test "start"
  generate_load
  set_accounting "false"
  signal_test "end"
  wait_container_timeout
  dump_bucket
}

function run_noserv_noacct {
  export test_name="4.noserv_noacct"
  export test_type="noserv"
  myecho "Running test ${test_name}"
  set-cont-template-cpu-current-to-max
  set_user_billing_type_current
  set_user_credit
  set_serverless "false"
  set_accounting "false"
  signal_test "start"
  generate_load
  signal_test "end"
  wait_container_timeout
  dump_bucket
}

function run_4_fold_exp {
  empty_bucket
  signal_exp "start"
  run_serv_acct
  run_serv_noacct
  run_noserv_acct
  run_noserv_noacct
  signal_exp "end"
}

function run_simple_exp {
  empty_bucket
  signal_exp "start"
  run_serv_acct
  signal_exp "end"
}

function activate_services {
  myecho "Activating Scaler"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/activate.sh)
  check_return_code201
  myecho "Activating Guardian"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/activate.sh)
  check_return_code201
  myecho "Activating CreditManager"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/activate.sh)
  check_return_code201
  myecho "Setting min GRC movement in CreditManager of ${MIN_COIN_MOVEMENT}"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh ${MIN_COIN_MOVEMENT})
  check_return_code201
}

function setup_exp {
  export EXP_OUT_DIR="${HOME}/exp_logs/${exp_name}"
  mkdir -p ${EXP_OUT_DIR}
  export LOGFILE=${EXP_OUT_DIR}/out.log
  activate_services
  configure_rules
  prepare_base_buckets
  set_timeout_container
  set_user_min_balance
  set_user_max_debt
  set_user_policy
  set-cont-template-cpu-max
  set-cont-template-cpu-boundary
}

source BDWatchdog/set_pythonpath.sh
export MONGODB_IP="193.144.50.38"
export MIN_COIN_MOVEMENT="0.05"

#POLICY="greedy"
#run_4_fold_exp

#POLICY="conservative"
#run_4_fold_exp
