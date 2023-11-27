ADDRESS="SDR8YWjMoh1CfkNdfX4Xxqh1CqxsCabjhE"
COINS=1
count=500
SLEEP_TIME=90
TIMESTAMPING_PATH="/home/jonatan/Desktop/development/BDWatchdog/TimestampsSnitch/src/timestamping"
source /home/jonatan/Desktop/development/BDWatchdog/set_pythonpath.sh


IP="192.168.51.240"
echo "Setting user0 balance to 0"
current_balance=$(gridcoinresearchd -rpcconnect="${IP}" -rpcport="9090" -rpcuser="gridcoinrpc" -rpcpassword="Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV" listaccounts | grep "user0" | sed "s/[\":,]//g" | sed "s/user0//")
move_amount=$(echo "0 - ${current_balance}" | bc | awk '{printf "%f", $0}')
echo "Current balance is ${current_balance}, desired one is 0, so amount to move is ${move_amount}"
if (( $(echo "$move_amount < 0" | bc -l) )); then
  move_amount=$(echo "-1 * ${move_amount}" | bc | awk '{printf "%f", $0}')
  gridcoinresearchd -rpcconnect="${IP}" -rpcport="9090" -rpcuser="gridcoinrpc" -rpcpassword="Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV" move user0 sink ${move_amount}
elif (( $(echo "$move_amount > 0" | bc -l) )); then
  gridcoinresearchd -rpcconnect="${IP}" -rpcport="9090" -rpcuser="gridcoinrpc" -rpcpassword="Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV" move sink user0 ${move_amount}
fi


first_time=1
for i in $(seq $count); do

  echo "Waiting until unix timestamp is modulo $SLEEP_TIME"
  sleep $(($SLEEP_TIME- $(date +%s) % $SLEEP_TIME))

	if [[ $first_time == 1 ]];
	then
	  python3 ${TIMESTAMPING_PATH}/signal_experiment.py start "GRC_EXP_2" --username="root" --push
	  first_time=0
	fi

  now=$(date +"%H:%M:%S")
	echo "Sending ${COINS} coins at ${now}"
	gridcoinresearchd sendfrom local ${ADDRESS} ${COINS}
done

echo "Waiting for 200 so the last transaction is surely processed"
sleep 200
python3 ${TIMESTAMPING_PATH}/signal_experiment.py end "GRC_EXP_2" --username="root" --push








