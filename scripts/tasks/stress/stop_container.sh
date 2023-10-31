scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/vars.sh
source ${scriptDir}/../../exp-vars.sh

sudo apptainer instance stop ${CONT_NAME}
curl -X DELETE -H "Content-Type: application/json" http://${HOST_1}:5000/structure/container/${CONT_NAME}
