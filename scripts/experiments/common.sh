function check_return_code201 {
  return_code="$http_code"
  if ! [[ ${return_code} =~ ^[0-9]+$ ]] || [[ "${return_code}" -ne "201" ]];
  then
    myecho "There was an error with this request, printed next"
    myecho "${return_code}"
    myecho "Stopping"
    exit 1
  fi
}

function myecho {
  message="[$(date "+%H:%M")] $1"
  echo ${message} >> "${LOGFILE}" 2>&1
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
  myecho "Signaling experiment test start"
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_test.py ${1} ${exp_name} ${test_name} --push --username root
}

function signal_exp {
  myecho "Signaling experiment ${1}"
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py ${1} ${exp_name} --push --username root
}

function set_serverless {
  myecho "Setting serverless to ${1}"
  apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-guard.sh ${1}
}

function set_accounting {
  myecho "Setting accounting to ${1}"
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting.sh user0 ${1})
  check_return_code201
}

function set_user_credit {
  myecho "Setting user credit"
  set_accounting "true"
  bash BlockchainServerless/scripts/gridcoin/set_user_balance.sh ${START_CREDIT}
  export http_code=$(apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_pending_zero.sh user0)
  check_return_code201
  sleep 15
  set_accounting "false"
}

function flush_remaining_consumed {
  myecho "Compute and flush the remaining consumed but not billed CPU"
  sleep 10
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.05
  myecho "Wait until it is billed"
  sleep 12
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh ${MIN_COIN_MOVEMENT}
}

function wait_container_timeout {
  myecho "Waiting container timeout (${TIMEOUT})"
  sleep $TIMEOUT
  sleep 10 # Plus some more just to be sure
}

function prepare_base_buckets {
  myecho "-------------------"
  myecho "Setting up basic buckets (utils and logs)"
  mc rm --force --recursive ${LOAD_BUCKET}/utils/ >> ${LOGFILE} 2>&1
  mc rm --force --recursive ${LOAD_BUCKET}/logs/ >> ${LOGFILE} 2>&1
  mc mb ${LOAD_BUCKET}/utils >> ${LOGFILE} 2>&1
  mc mb ${LOAD_BUCKET}/logs >> ${LOGFILE} 2>&1
  myecho "-------------------"
  myecho "Copying the 'process_task.sh' script for this load to the 'utils' bucket in '${LOAD_BUCKET}'"
  mc cp BlockchainServerless/scripts/tasks/${LOAD_NAME}/process_task.sh ${LOAD_BUCKET}/utils/  >> ${LOGFILE} 2>&1
  myecho "Copying the '${LOAD_NAME}.sif' container image for this load to the 'utils' bucket in '${LOAD_BUCKET}'"
  mc cp "${LOAD_NAME}.sif" ${LOAD_BUCKET}/utils/  >> ${LOGFILE} 2>&1
}

function empty_bucket {
  myecho "-------------------"
  myecho "Emptying buckets"
  mc rm --force --recursive ${LOAD_BUCKET}/results/ >> ${LOGFILE} 2>&1
  mc rm --force --recursive ${LOAD_BUCKET}/input/ >> ${LOGFILE} 2>&1
  mc rm --force --recursive ${LOAD_BUCKET}/processing/ >> ${LOGFILE} 2>&1
  mc rm --force --recursive ${LOAD_BUCKET}/output/ >> ${LOGFILE} 2>&1
  mc mb ${LOAD_BUCKET}/results >> ${LOGFILE} 2>&1
  mc mb ${LOAD_BUCKET}/input >> ${LOGFILE} 2>&1
  mc mb ${LOAD_BUCKET}/processing >> ${LOGFILE} 2>&1
  mc mb ${LOAD_BUCKET}/output >> ${LOGFILE} 2>&1
  myecho "-------------------"
}

function dump_bucket_info {
  myecho "-------------------"
  myecho "Bucket content is: "
  mc ls --recursive ${LOAD_BUCKET}/  >> ${LOGFILE} 2>&1
  empty_bucket
  myecho "-------------------"
}

function set_timeout_container {
  myecho "Setting timeout of ${TIMEOUT}"
  echo ${TIMEOUT} >timeout.txt
  mc cp timeout.txt ${LOAD_BUCKET}/utils  >> ${LOGFILE} 2>&1
}

function set-cont-template-cpu-max {
  myecho "Setting the cpu 'current' to the maximum allowed in the container template"
  apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-current-to-max.sh
}

function set-cont-template-cpu-halfmax {
  myecho "Setting the cpu 'current' to the half the maximum allowed in the container template"
  apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-current-to-half-max.sh
}

function set-cont-template-name {
  CONT_NAME="${LOAD_NAME}-cont"
  myecho "Setting the name (${CONT_NAME}) in the container template"
  apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-name.sh ${CONT_NAME}
}

function set_out_log {
  mkdir -p ${OUT_DIR}/${test_name}
  export LOGFILE=${OUT_DIR}/${test_name}/out.log
}

function run_serv_acct {
  export test_name="1.${LOAD_NAME}_serv_acct"
  set_out_log
  myecho "Running test ${test_name}"
  set-cont-template-cpu-halfmax
  set_user_credit
  set_serverless "true"
  set_accounting "true"
  signal_test "start"
  generate_load
  set_serverless "false"
  flush_remaining_consumed
  set_accounting "false"
  signal_test "end"
  dump_bucket_info
  wait_container_timeout
}

function run_serv_noacct {
  export test_name="2.${LOAD_NAME}_serv_noacct"
  set_out_log
  myecho "Running test ${test_name}"
  set-cont-template-cpu-halfmax
  set_user_credit
  set_serverless "true"
  set_accounting "false"
  signal_test "start"
  generate_load
  set_serverless "false"
  flush_remaining_consumed
  signal_test "end"
  dump_bucket_info
  wait_container_timeout
}

function run_noserv_acct {
  export test_name="3.${LOAD_NAME}_noserv_acct"
  set_out_log
  myecho "Running test ${test_name}"
  set-cont-template-cpu-max
  set_user_credit
  set_serverless "false"
  set_accounting "true"
  signal_test "start"
  generate_load
  flush_remaining_consumed
  set_accounting "false"
  signal_test "end"
  dump_bucket_info
  wait_container_timeout
}

function run_noserv_noacct {
  export test_name="4.${LOAD_NAME}_noserv_noacct"
  set_out_log
  myecho "Running test ${test_name}"
  set-cont-template-cpu-max
  set_user_credit
  set_serverless "false"
  set_accounting "false"
  signal_test "start"
  generate_load
  flush_remaining_consumed
  signal_test "end"
  dump_bucket_info
  wait_container_timeout
}

function run_4_fold_exp {
  TIMESTAMP=$(date "+%m_%d_%H:%M")
  export OUT_DIR=${EXP_OUT_DIR}/${TIMESTAMP}/${POLICY}
  mkdir -p ${OUT_DIR}
  set_user_policy
  empty_bucket
  export exp_name="${TIMESTAMP}_${POLICY}"
  signal_exp "start"
  run_serv_acct
  run_serv_noacct
  run_noserv_acct
  run_noserv_noacct
  signal_exp "end"
}

function run_simple_test {
  TIMESTAMP=$(date "+%m_%d_%H:%M")
  export OUT_DIR="${EXP_OUT_DIR}/${TIMESTAMP}/test"
  mkdir -p ${OUT_DIR}
  set_user_policy
  empty_bucket
  export exp_name="${TIMESTAMP}_test"
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


source BDWatchdog/set_pythonpath.sh
export MONGODB_IP="193.144.50.38"
export EXP_OUT_DIR="${HOME}/exp_logs"
export LOGFILE=${EXP_OUT_DIR}/out.log

mkdir -p ${EXP_OUT_DIR}
rm -f LOGFILE

export MIN_COIN_MOVEMENT="0.2"
export LOAD_BUCKET="myminio/${LOAD_NAME}"

activate_services
prepare_base_buckets
set_timeout_container
set_user_min_balance
set_user_max_debt
set-cont-template-name

POLICY="conservative"
run_simple_test

#POLICY="greedy"
#run_4_fold_exp

#POLICY="conservative"
#run_4_fold_exp
