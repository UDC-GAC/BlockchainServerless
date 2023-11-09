#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 1', el nodo auxiliar
# usado para levantar el framework de Serverless Containers y cualquier 
# otro programa necesario para la ejecucion de los experimentos

source BlockchainServerless/scripts/exp-vars.fish

# Levantar la StateDatabase (Couchdb)
rm -Rf {$COUCHDB_DATA} && mkdir {$COUCHDB_DATA}
apptainer instance start --bind {$COUCHDB_DATA}:/opt/couchdb/data --hostname couchdb couchdb.sif couchdb
tmux new -d -s "Couchdb" "apptainer exec instance://couchdb /opt/couchdb/bin/couchdb"
echo "Waiting for couchdb to start"
sleep 10

# Desplegar MinIO
rm -Rf {$MINIO_DATA} &&  mkdir {$MINIO_DATA}
apptainer instance start --hostname minio --bind {$MINIO_DATA}:/data minio_latest.sif minio
tmux new -d -s "Minio" "apptainer exec instance://minio /bin/minio server /data/"


# Levantar el contenedor de SC
apptainer instance start --hostname sc --bind /home/jonatan.enes/myhosts:/etc/hosts sc.sif sc

# Arrancar el Orquestador y configurar el entorno
tmux new -d -s "Orchestrator" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/orchestrator/start.sh"
apptainer exec instance://sc bash ServerlessContainers/conf/create_basics.sh
apptainer exec instance://sc bash ServerlessContainers/conf/subscribe_all.sh

# Arrancar los otros servicios
tmux new -d -s "Guardian" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/guardian/start.sh"
tmux new -d -s "Scaler" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/scaler/start.sh"
tmux new -d -s "DatabaseSnapshoter" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/database_snapshoter/start.sh"
tmux new -d -s "StructuresSnapshoter" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/structure_snapshoter/start.sh"
tmux new -d -s "Refeeder" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/refeeder/start.sh"
tmux new -d -s "CreditManager" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/credit_manager/start.sh"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_rpc_ip.sh "193.144.50.38"


exit 0

#####################
apptainer exec instance://sc export PYTHONPATH=/home/jonatan.enes/ServerlessContainers && python3 ServerlessContainers/conf/CheckAlive/CheckAlive.py