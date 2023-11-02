echo "----------------------"
echo "Processing task of type Stress"

if [ "$#" -lt 2 ]
then
  echo "2 arguments are needed"
  echo "+ the name of the container to use to run the load"
  echo "+ the name of the file (task)"
  exit 1
fi

CONT_NAME=$1
TASK_NAME=$2

echo "Moving the file from input to processing"
mc mv myminio/stress/input/${TASK_NAME} myminio/stress/processing/${TASK_NAME}

echo "Running the load now"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
file=$(echo ${TASK_NAME} | sed "s/.txt//g")
num_core=$(echo $file | cut -d "." -f 2 | cut -d "-" -f 1)
runtime=$(echo $file | cut -d "." -f 2| cut -d "-" -f 2)
echo "Will run a stress load with ${num_core} cores for ${runtime} seconds"
sudo apptainer exec instance://${CONT_NAME} stress -c ${num_core} -t ${runtime}
exit_code=$?
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"

echo "Status code of command executed is ${exit_code}"
if [[ ${exit_code} -ne 0 ]]; then
  echo "There was an error running the last task"
  echo "Moving the file from processing back to input"
  mc mv myminio/stress/processing/${TASK_NAME} myminio/stress/input/${TASK_NAME}
else
  echo "Moving the file from processing to output"
  mc mv myminio/stress/processing/${TASK_NAME} myminio/stress/output/${TASK_NAME}
fi
echo "----------------------"