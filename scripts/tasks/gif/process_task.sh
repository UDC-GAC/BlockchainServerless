echo "----------------------"
echo "Processing task of type GIF"

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
OUT_FILE=$(echo ${IN_FILE} | sed 's/mp4/gif/g')

echo "Running the gif function now"
echo "Taskfile is ${TASK_NAME}"
echo "Input file is ${IN_FILE}"
echo "Results dir are ${OUT_DIR}"
echo "Resulting file will be ${OUT_FILE}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
ffmpeg -y -i ${TASK_NAME} -t 10 -vf "fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "${OUT_DIR}/${OUT_FILE}"
exit_code=$?
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
exit $exit_code
