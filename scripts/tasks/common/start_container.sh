scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/../../exp-vars.sh

if [ "$#" -lt 2 ]
then
  echo "2 arguments are needed:"
  echo " + the name of the container to stop"
  echo " + the name of the container image"
  exit 1
fi

CONT_NAME=$1
SIF_IMAGE="/home/jonatan.enes/$2.sif"

echo "----------------------"
echo "Container start script"
echo "Container will be named ${CONT_NAME}"
echo "Container image used will be ${SIF_IMAGE}"

echo "" > cgroups_file.toml
mkdir -p /tmp/screen-run
sudo apptainer instance start --hostname ${CONT_NAME} --bind /tmp/screen-run/:/run/ --apply-cgroups cgroups_file.toml ${SIF_IMAGE} ${CONT_NAME}
if [[ $? -ne 0 ]]; then
  echo "There was an error starting the container"
  exit 1
fi

rm cgroups_file.toml
python3 /home/jonatan.enes/change_cgroupsv1_permissions.py apptainer singularity ${CONT_NAME}
#tmux new -d -s "ATOP-${CONT_NAME}" "sudo apptainer exec instance://${CONT_NAME} bash /home/jonatan.enes/BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh"
sudo apptainer exec instance://${CONT_NAME} screen -d -m bash /home/jonatan.enes/BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh


## Generate a spurious very low load so that a first cpu metric (with very low consumption) is sent
#sudo apptainer exec instance://${CONT_NAME} echo "Running spurious task" && ls -lash -R /sys/ /usr/ &> /dev/null

# This should take an additional 1 to 2 seconds
http_code1=$(curl -X PUT -H "Content-Type: application/json" --output /tmp/pet1.log -s -w "%{http_code}" http://${HOST_1}:5000/structure/container/${CONT_NAME} --data @${scriptDir}/cont-layout.json)
http_code2=$(curl -X PUT -H "Content-Type: application/json" --output /tmp/pet2.log -s -w "%{http_code}" http://${HOST_1}:5000/structure/container/${CONT_NAME}/app0)
if [[ ${http_code1} -ne "200" ]] || [[ ${http_code2} -ne "200" ]]; then
  echo "There was an error subscribing the container in the Serverless Platform, stopping the container"
  cat /tmp/pet1.log
  cat /tmp/pet2.log
  sudo apptainer instance stop ${CONT_NAME}
  exit 1
fi

echo "Waiting a few seconds so that the container can send usage metrics"
sleep 5

echo "----------------------"