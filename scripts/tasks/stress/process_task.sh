scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/../common/vars.sh

file=$(echo $1 | sed "s/.txt//g")
num_core=$(echo $file | cut -d "." -f 2 | cut -d "-" -f 1)
runtime=$(echo $file | cut -d "." -f 2| cut -d "-" -f 2)
echo "Will run a stress load with ${num_core} cores for ${runtime} seconds"
echo "Moving the file from input to processing"
mc mv myminio/stress/input/$1 myminio/stress/processing/$1
echo "Running the load now"
sudo apptainer exec instance://${CONT_NAME} stress -c ${num_core} -t ${runtime}
exit_code=$?
echo "Status code of command executed is ${exit_code}"
if [[ ${exit_code} -ne 0 ]]; then
  echo "There was an error running the last task"
  echo "Moving the file from processing back to input"
  mc mv myminio/stress/processing/$1 myminio/stress/input/$1
else
  echo "Moving the file from processing to output"
  mc mv myminio/stress/processing/$1 myminio/stress/output/$1
fi
