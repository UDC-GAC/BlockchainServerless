export CONT_NAME="cont0"
echo "" > cgroups_file.toml
sudo apptainer instance start --hostname ${CONT_NAME} --apply-cgroups cgroups_file.toml experiment.sif ${CONT_NAME}
python3 change_cgroupsv1_permissions.py apptainer singularity ${CONT_NAME}
tmux new -d -s "ATOP-${CONT_NAME}" "sudo apptainer exec instance://${CONT_NAME} bash /home/jonatan.enes/BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh"

curl -X PUT -H "Content-Type: application/json" http://10.10.255.231:5000/structure/container/${CONT_NAME} --data @cont-layout.json
curl -X PUT -H "Content-Type: application/json" http://10.10.255.231:5000/structure/container/${CONT_NAME}/app0