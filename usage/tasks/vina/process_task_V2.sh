LOAD_FUNC="Vina (AutoDoc)"

echo "----------------------"
echo "Processing task of type ${LOAD_FUNC}"
if [ "$#" -lt 2 ]
then
  echo "2 arguments are expected"
  echo "+ the path of the joined ligand+receptor .tar.gz file"
  echo "+ the path for the output files"
  exit 1
fi


echo "Running the ${LOAD_FUNC} function now with the task ${1}"
echo "Time is $(date "+%H:%M")"
start_time=$(date "+%s")

StagingDir="/staging/results"
mkdir -p ${StagingDir}
echo "Moving to staging dir ${StagingDir}"
TASK_NAME=$(basename "$1")
mv $1 ${StagingDir}/${TASK_NAME}
cd ${StagingDir}

tar xvf ${TASK_NAME}

echo "Staging dir contents are"
ls -lash

BASE_FILE="$(basename "$1" | sed 's/.tar.gz//g')"
LIGAND_FILE="${BASE_FILE}_ligand.pdbqt"
RECEPTOR_FILE="${BASE_FILE}_receptor.pdbqt"
OUT_FILE="${BASE_FILE}_out.pdbqt"

OUT_DIR=$2

echo "Results dir are ${OUT_DIR}"
echo "Input receptor file is ${RECEPTOR_FILE}"
echo "Input ligand file is ${LIGAND_FILE}"
echo "Resulting file will be ${OUT_FILE} stored in ${OUT_DIR}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

rm -f ${OUT_DIR}/${OUT_FILE}
/usr/bin/time -v vina --receptor "${RECEPTOR_FILE}" --ligand "${LIGAND_FILE}" --out "${OUT_DIR}/${OUT_FILE}" \
     --center_x 15.19 --center_y 53.90 --center_z 16.92 \
     --size_x 30 --size_y 30 --size_z 30 \
     --exhaustiveness 32 --cpu 4 --num_modes 20 --seed 42
exit_code=$?


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
end_time=$(date "+%s")
time_diff=$(echo "${end_time} - ${start_time}" | bc)
echo "Time is $(date "+%H:%M"), it took ${time_diff} seconds"
echo "Checksum of result file ${OUT_DIR}/${OUT_FILE} is $(md5sum "${OUT_DIR}/${OUT_FILE}")"

exit $exit_code
