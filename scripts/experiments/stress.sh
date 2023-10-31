function generate_load {
  echo "Generate the tasks"
  #LOAD="1-150" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #LOAD="2-100" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #LOAD="1-50" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #LOAD="2-150" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #echo "Waiting"
  #sleep 500
  LOAD="2-200" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  echo "Waiting"
  sleep 250
}

source BDWatchdog/set_pythonpath.sh
export MONGODB_IP="193.144.50.38"


export exp_name="stress_serv_acct"
echo "Setting user credit"
bash BlockchainServerless/scripts/gridcoin/set_zero_balance.sh
apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh move sink user0 10
echo "Signaling experiment start"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py start ${exp_name} --push --username root
echo "Activating Serverless"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/activate.sh
apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/set-cont-guard.sh true
echo "Activating Accounting"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/activate.sh
echo "Run the load"
generate_load
echo "Deactivate Serverless"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/deactivate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/deactivate.sh
echo "Flush the remaining consumed but not billed amount"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.01
sleep 15
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.1
echo "Deactivate Accounting"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/deactivate.sh
echo "Signaling experiment end"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py end ${exp_name} --push --username root
echo "Stopping the container"
bash BlockchainServerless/scripts/tasks/stress/stop_container.sh

sleep 60

export exp_name="stress_serv_noacct"
echo "Setting user credit"
bash BlockchainServerless/scripts/gridcoin/set_zero_balance.sh
apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh move sink user0 10
echo "Signaling experiment start"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py start ${exp_name} --push --username root
echo "Activating Serverless"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/activate.sh
apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/set-cont-guard.sh true
echo "Deactivating Accounting"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/deactivate.sh
echo "Run the load"
generate_load
echo "Deactivate Serverless"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/deactivate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/deactivate.sh
echo "Signaling experiment end"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py end ${exp_name} --push --username root
echo "Stopping the container"
bash BlockchainServerless/scripts/tasks/stress/stop_container.sh

sleep 60

export exp_name="stress_noserv_acct"
echo "Setting user credit"
bash BlockchainServerless/scripts/gridcoin/set_zero_balance.sh
apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh move sink user0 10
echo "Signaling experiment start"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py start ${exp_name} --push --username root
echo "Deactivating Serverless"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/deactivate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/deactivate.sh
apptainer exec instance://sc bash BlockchainServerless/scripts/tasks/set-cont-guard.sh false
echo "Activating Accounting"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/activate.sh
echo "Run the load"
generate_load
echo "Flush the remaining consumed but not billed amount"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.01
sleep 15
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_min_coin_movement.sh 0.1
echo "Deactivate Accounting"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/deactivate.sh
echo "Signaling experiment end"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py end ${exp_name} --push --username root
echo "Stopping the container"
bash BlockchainServerless/scripts/tasks/stress/stop_container.sh

sleep 60

export exp_name="stress_noserv_noacct"
echo "Setting user credit"
bash BlockchainServerless/scripts/gridcoin/set_zero_balance.sh
apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh move sink user0 10
echo "Signaling experiment start"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py start ${exp_name} --push --username root
echo "Deactivate Serverless"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/deactivate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/deactivate.sh
echo "Deactivate Accounting"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/deactivate.sh
echo "Run the load"
generate_load
echo "Signaling experiment end"
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py end ${exp_name} --push --username root
echo "Stopping the container"
bash BlockchainServerless/scripts/tasks/stress/stop_container.sh



