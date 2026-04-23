scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
#source ${scriptDir}/../../exp-vars.sh
export ORCHESTRATOR_HOST="127.0.0.1"

if [ "$#" -lt 1 ]
then
  echo "1 argument needed, the name of the container to stop"
  exit 1
fi

CONT_NAME=$1

sudo apptainer instance stop ${CONT_NAME}
curl -X DELETE -H "Content-Type: application/json" http://${ORCHESTRATOR_HOST}:5000/structure/container/${CONT_NAME}
