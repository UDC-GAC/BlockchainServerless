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

BASE_FILE="$(basename "$1" | sed 's/.zip//g')"

rm -Rf /staging/results/

StagingDir="/staging/results/${BASE_FILE}"
mkdir -p ${StagingDir}
echo "Moving to staging dir ${StagingDir}"
TASK_NAME=$(basename "$1")
mv $1 ${StagingDir}/${TASK_NAME}
cd ${StagingDir}

#tar xvf ${TASK_NAME}
unzip -o ${TASK_NAME}
echo "Staging dir contents are"
ls -lash


#EXH=16 # This knob tunes the duration of the second, parallel phase
#NPTS=128 # This knob tunes the duration of the first, sequential phase
source config.env
echo "Running task with exhaustivity of ${EXH} and npts of ${NPTS}"
VINA_SPACING=0.225
CX=15.190; CY=53.903; CZ=16.917   # 1IEP ATP-binding site

PAR_DEGREE=18

OUT_DIR=$2


LIGAND_FILE="ligand.pdbqt"
RECEPTOR_FILE="receptor.pdbqt"
OUT_FILE="${BASE_FILE}_out.pdbqt"

echo "Results dir are ${OUT_DIR}"
echo "Input receptor file is ${RECEPTOR_FILE}"
echo "Input ligand file is ${LIGAND_FILE}"
echo "Resulting file will be ${OUT_FILE} stored in ${OUT_DIR}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

LTYPES=$(awk '/^(ATOM|HETATM)/{print $NF}' ${LIGAND_FILE} | grep -vE '^(G[0-9]|CG[0-9])$' | sort -u | tr '\n' ' ')
RTYPES=$(awk '/^(ATOM|HETATM)/{print $NF}' ${RECEPTOR_FILE} | sort -u | tr '\n' ' ')
 {
  echo "npts $NPTS $NPTS $NPTS"
  echo "gridfld rec.maps.fld"
  echo "spacing ${VINA_SPACING}"
  echo "receptor_types $RTYPES"
  echo "ligand_types $LTYPES"
  echo "receptor ${RECEPTOR_FILE}"
  echo "gridcenter $CX $CY $CZ"
  echo "smooth 0.500"
  for t in $LTYPES; do echo "map rec.${t}.map"; done
  echo "elecmap rec.e.map"
  echo "dsolvmap rec.d.map"
  echo "dielectric -0.1465"
} > grid.gpf

# ---- PHASE 1: serial ---------------------------------------------------------
autogrid4 -p grid.gpf -l grid.glg

ls -lash

# ---- PHASE 2: parallel -------------------------------------------------------
rm -f ${OUT_DIR}/${OUT_FILE}
/usr/bin/time -v vina \
     --scoring ad4 \
     --maps rec \
     --ligand "${LIGAND_FILE}" \
     --out "${OUT_DIR}/${OUT_FILE}" \
     --exhaustiveness "${EXH}" \
     --cpu ${PAR_DEGREE} \
     --num_modes 20 \
     --seed 42
exit_code=$?

## These commands again generate a final sequential phase
#tar -cf maps.tar rec.*.map rec.maps.fld
#/usr/bin/time -v gzip -9 maps.tar
#cp maps.tar.gz ${OUT_DIR}/maps.tar.gz

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Finished running the load"
end_time=$(date "+%s")
time_diff=$(echo "${end_time} - ${start_time}" | bc)
echo "Time is $(date "+%H:%M"), it took ${time_diff} seconds"
echo "Checksum of result file ${OUT_DIR}/${OUT_FILE} is $(md5sum "${OUT_DIR}/${OUT_FILE}")"

echo "Removing staging dir for this task in ${StagingDir}"
rm -Rf ${StagingDir}

exit $exit_code
