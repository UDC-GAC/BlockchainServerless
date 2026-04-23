LOAD_FUNC="Stress"

echo "----------------------"
echo "Processing task of type ${LOAD_FUNC}"
if [ "$#" -lt 2 ]
then
  echo "2 arguments are expected"
  echo "+ the path of the file (task)"
  echo "+ the path for the output files"
  exit 1
fi
TASK_NAME=$1
OUT_DIR=$2
echo "Running the ${LOAD_FUNC} function now"
echo "Time is $(date "+%H:%M")"
start_time=$(date "+%s")
echo "Taskfile is ${TASK_NAME}"
echo "Results dir are ${OUT_DIR}"
IN_FILE=$(basename ${TASK_NAME})
OUT_FILE="$(echo ${IN_FILE} | sed 's/.txt//g')_success.txt"
echo "Input file is ${IN_FILE}"
echo "Resulting file will be ${OUT_FILE}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

file=$(echo ${TASK_NAME} | sed "s/.txt//g")
num_core=$(echo "$file" | cut -d "." -f 3 | cut -d "-" -f 1)
runtime=$(echo "$file" | cut -d "." -f 3 | cut -d "-" -f 2)
echo "Will run a stress load with ${num_core} cores for ${runtime} seconds"
/usr/bin/time -v stress -c "${num_core}" -t "${runtime}"
exit_code=$?
echo "success" > "${OUT_FILE}"
cp ${OUT_FILE} ${OUT_DIR}/
echo "Generating a result file named '${OUT_FILE}' stored in '${OUT_DIR}'"

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
end_time=$(date "+%s")
time_diff=$((start_time - end_time))
echo "Time is $(date "+%H:%M"), it took ${time_diff} seconds"
echo "Doing checksum of result file ${OUT_DIR}/${OUT_FILE}"
md5sum "${OUT_DIR}/${OUT_FILE}"
exit $exit_code
