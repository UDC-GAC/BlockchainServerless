scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/vars.sh
source ${scriptDir}/../../exp-vars.sh

echo "" > cgroups_file.toml
sudo apptainer instance start --hostname ${CONT_NAME} --apply-cgroups cgroups_file.toml ${SIF_IMAGE} ${CONT_NAME}
rm cgroups_file.toml
python3 /home/jonatan.enes/change_cgroupsv1_permissions.py apptainer singularity ${CONT_NAME}
tmux new -d -s "ATOP-${CONT_NAME}" "sudo apptainer exec instance://${CONT_NAME} bash /home/jonatan.enes/BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh"


curl -X PUT -H "Content-Type: application/json" http://${HOST_1}:5000/structure/container/${CONT_NAME} --data @${scriptDir}/cont-layout.json
curl -X PUT -H "Content-Type: application/json" http://${HOST_1}:5000/structure/container/${CONT_NAME}/app0