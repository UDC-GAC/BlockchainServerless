echo "----------------------"
echo "Processing task of type Stress"

if [ "$#" -lt 1 ]
then
  echo "1 argument is needed"
  echo "+ the name of the file (task)"
  exit 1
fi

TASK_NAME=$1

echo "Running the load now"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
file=$(echo ${TASK_NAME} | sed "s/.txt//g")
num_core=$(echo $file | cut -d "." -f 2 | cut -d "-" -f 1)
runtime=$(echo $file | cut -d "." -f 2| cut -d "-" -f 2)
echo "Will run a stress load with ${num_core} cores for ${runtime} seconds"
stress -c ${num_core} -t ${runtime}
exit_code=$?
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
exit $exit_code
