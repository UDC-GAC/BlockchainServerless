echo "----------------------"
echo "Processing task of type transcoding (mp4 -> webm)"

if [ "$#" -lt 2 ]
then
  echo "2 arguments are expected"
  echo "+ the name of the file (task)"
  echo "+ the path for the output files"
  exit 1
fi

TASK_NAME=$1
OUT_DIR=$2

IN_FILE=$(basename ${TASK_NAME})
OUT_FILE=$(echo ${IN_FILE} | sed 's/mp4/webm/g')

echo "Running the gif function now"
echo "Taskfile is ${TASK_NAME}"
echo "Input file is ${IN_FILE}"
echo "Results dir are ${OUT_DIR}"
echo "Resulting file will be ${OUT_FILE}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
ffmpeg -i  ${TASK_NAME} -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus -threads 8 "${OUT_DIR}/${OUT_FILE}"
exit_code=$?
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
exit $exit_code
