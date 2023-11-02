function generate_load {
  echo "Generate the tasks"
  LOAD="0.1-150" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  LOAD="1.2-100" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  LOAD="2.1-100" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  LOAD="3.3-200" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  LOAD="4.1-101" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  LOAD="5.2-101" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  LOAD="6.1-50" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  echo "Waiting"
  sleep 810
  LOAD="7.2-200" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  echo "Waiting"
  sleep 210

#  LOAD="1-300" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
#  sleep 310
}

function signal_test_start {
  echo "Signaling experiment test start"
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_test.py start ${exp_name} ${test_name} --push --username root
}

function signal_test_end {
  echo "Signaling experiment test end"
  sleep 10
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_test.py end ${exp_name} ${test_name} --push --username root
}

function signal_exp_start {
  echo "Signaling experiment start"
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py start ${exp_name} --push --username root
  sleep 15
}

function signal_exp_end {
  echo "Signaling experiment end"
  sleep 15
  python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py end ${exp_name} --push --username root
}

function deactivate_serverless {
  echo "Deactivating Serverless"
  #apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/deactivate.sh
  #apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/deactivate.sh
  apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-guard.sh false
}

function activate_serverless {
  echo "Activating Serverless"
  #apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/activate.sh
  #apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/activate.sh
  apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-guard.sh true
}

function activate_accounting {
  echo "Activating Accounting"
  #apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/activate.sh
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/activate_user_accounting.sh user0
}

function deactivate_accounting {
  echo "Deactivating Accounting"
  #apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/deactivate.sh
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/deactivate_user_accounting.sh user0
}

function stop_container {
  sleep 15
  echo "Stopping the container"
  bash BlockchainServerless/scripts/tasks/common/stop_container.sh
}

function set_user_credit {
  START_CREDIT=40
  echo "Setting user credit"
  activate_accounting
  bash BlockchainServerless/scripts/gridcoin/set_zero_balance.sh
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/set_accounting_pending_zero.sh user0
  apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh move sink user0 ${START_CREDIT}
  sleep 15
  deactivate_accounting
}

function flush_remaining_consumed {
  echo "Compute and flush the remaining consumed but not billed CPU"
  sleep 10
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.05
  echo "Wait until it is billed"
  sleep 12
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.2
}

function wait_interlude {
  sleep 45
}

apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.2

source BDWatchdog/set_pythonpath.sh
export MONGODB_IP="193.144.50.38"

export exp_name=$(date "+%F_%H:%M")
signal_exp_start

export test_name="1.stress_serv_acct"
apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-current-to-half-max.sh
set_user_credit
activate_serverless
activate_accounting
signal_test_start
generate_load
deactivate_serverless
flush_remaining_consumed
deactivate_accounting
signal_test_end
stop_container
wait_interlude

export test_name="2.stress_serv_noacct"
apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-current-to-half-max.sh
set_user_credit
activate_serverless
deactivate_accounting
signal_test_start
generate_load
deactivate_serverless
flush_remaining_consumed
signal_test_end
stop_container
wait_interlude


export test_name="3.stress_noserv_acct"
apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-current-to-max.sh
set_user_credit
deactivate_serverless
activate_accounting
signal_test_start
generate_load
flush_remaining_consumed
deactivate_accounting
signal_test_end
stop_container
wait_interlude


export test_name="4.stress_noserv_noacct"
apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/common/set-cont-current-to-max.sh
set_user_credit
deactivate_serverless
deactivate_accounting
signal_test_start
generate_load
flush_remaining_consumed
signal_test_end
stop_container
wait_interlude

signal_exp_end
