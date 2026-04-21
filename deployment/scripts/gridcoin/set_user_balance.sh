scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

if [ "$#" -lt 1 ]
then
  echo "1 argument needed, the balance desired for user0"
  exit 1
fi

desired=$1
current_balance=$(apptainer exec instance://grc bash ${scriptDir}/gridcoin-run.sh listaccounts | grep "user0" | sed "s/[\":,]//g" | sed "s/user0//")
move_amount=$(echo "${desired} - ${current_balance}" | bc | awk '{printf "%f", $0}')
echo "Current balance is ${current_balance}, desired one is ${desired}, so amount to move is ${move_amount}"
if (( $(echo "$move_amount < 0" | bc -l) )); then
  move_amount=$(echo "-1 * ${move_amount}" | bc | awk '{printf "%f", $0}')
  apptainer exec instance://grc bash ${scriptDir}/gridcoin-run.sh move user0 sink ${move_amount}
elif (( $(echo "$move_amount > 0" | bc -l) )); then
  apptainer exec instance://grc bash ${scriptDir}/gridcoin-run.sh move sink user0 ${move_amount}
fi

