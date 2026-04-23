scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
#source ${scriptDir}/../../exp-vars.sh
export ORCHESTRATOR_HOST="127.0.0.1"

if [ "$#" -lt 3 ]
then
  echo "3 arguments are needed:"
  echo " + the name of the container to start"
  echo " + the path to the container image"
  echo " + the path to the staging directory"
  exit 1
fi

CONT_NAME=$1
SIF_IMAGE=$2
STAG_DIR=$3

echo "----------------------"
echo "Container start script"
echo "Container will be named '${CONT_NAME}'"
echo "Container image used will be '${SIF_IMAGE}'"
echo "Staging directory located at '${STAG_DIR}'"

cat /etc/hosts > /tmp/cont-hosts.txt
echo "127.0.0.1 ${CONT_NAME}" >> /tmp/cont-hosts.txt

echo "" > cgroups_file.toml
mkdir -p /tmp/screen-run
sudo apptainer instance start --hostname "${CONT_NAME}" --bind /tmp/cont-hosts.txt:/etc/hosts --bind /tmp/screen-run/:/run/ --bind ${STAG_DIR}:/staging --apply-cgroups cgroups_file.toml ${SIF_IMAGE} ${CONT_NAME}
if [[ $? -ne 0 ]]; then
  echo "There was an error starting the container"
  exit 1
fi

rm cgroups_file.toml
python3 /home/jonatan.enes/change_cgroups_permissions.py v1 apptainer singularity "${CONT_NAME}"
sudo apptainer exec instance://${CONT_NAME} screen -d -m bash /home/jonatan.enes/BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh

# This should take an additional 1 to 2 seconds
http_code1=$(curl -X PUT -H "Content-Type: application/json" --output /tmp/pet1.log -s -w "%{http_code}" http://${ORCHESTRATOR_HOST}:5000/structure/container/${CONT_NAME} --data @${scriptDir}/cont-layout.json)
http_code2=$(curl -X PUT -H "Content-Type: application/json" --output /tmp/pet2.log -s -w "%{http_code}" http://${ORCHESTRATOR_HOST}:5000/structure/container/${CONT_NAME}/app0)
if [[ ${http_code1} -ne "200" ]] || [[ ${http_code2} -ne "200" ]]; then
  echo "There was an error subscribing the container in the Serverless Platform, stopping the container"
  echo "Output from trying to subscribe container was:"
  cat /tmp/pet1.log
  echo "Output from trying to subscribe container to app was:"
  cat /tmp/pet2.log
  echo "Stopping the actually started container"
  sudo apptainer instance stop ${CONT_NAME}
  exit 1
fi

echo "Waiting a few seconds so that the container can send usage metrics"
sleep 5

echo "----------------------"
