LOAD_FUNC="Transcoding (mp4 -> webm)"

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
OUT_FILE=$(echo ${IN_FILE} | sed 's/mp4/webm/g')
echo "Input file is ${IN_FILE}"
echo "Resulting file will be ${OUT_FILE}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

/usr/bin/time -v ffmpeg -i  ${TASK_NAME} -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus -threads 16 "${OUT_DIR}/${OUT_FILE}"
exit_code=$?


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
end_time=$(date "+%s")
time_diff=$(echo "${end_time} - ${start_time}" | bc)
echo "Time is $(date "+%H:%M"), it took ${time_diff} seconds"
echo "Doing checksum of result file ${OUT_DIR}/${OUT_FILE}"
md5sum "${OUT_DIR}/${OUT_FILE}"
exit $exit_code
