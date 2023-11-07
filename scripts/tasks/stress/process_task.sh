echo "----------------------"
echo "Processing task of type Stress"

if [ "$#" -lt 2 ]
then
  echo "2 arguments are expected"
  echo "+ the path of the file (task)"
  echo "+ the path for the output files"
  exit 1
fi

TASK_NAME=$1
OUT_DIR=$2

echo "Running the stress function now"
echo "Taskfile is ${TASK_NAME}"
echo "Results dir are ${OUT_DIR}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
file=$(echo ${TASK_NAME} | sed "s/.txt//g")
num_core=$(echo "$file" | cut -d "." -f 2 | cut -d "-" -f 1)
runtime=$(echo "$file" | cut -d "." -f 2| cut -d "-" -f 2)
echo "Will run a stress load with ${num_core} cores for ${runtime} seconds"
stress -c "${num_core}" -t "${runtime}"
exit_code=$?
echo "success" > "${file}_success.txt"
cp ${file}_success.txt ${OUT_DIR}/
echo "Generating a result file named '${file}_success.txt' stored in '${OUT_DIR}'"

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
exit $exit_code
