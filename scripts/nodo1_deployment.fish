#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 1', el nodo auxiliar
# usado para levantar el framework de Serverless Containers y cualquier 
# otro programa necesario para la ejecucion de los experimentos

# Construir los contenedores
apptainer build --force couchdb.sif my_couchdb.def
apptainer build --force sc.sif sc.def
apptainer build --force gridcoin.sif gridcoin.def

# Levantar la StateDatabase (Couchdb)
set -gx COUCHDB_DATA "/scratch2/couchdb-data"
rm -Rf {$COUCHDB_DATA}
mkdir {$COUCHDB_DATA}
apptainer instance start --bind {$COUCHDB_DATA}:/opt/couchdb/data --hostname couchdb couchdb.sif couchdb
tmux new -s "Couchdb" "apptainer exec instance://couchdb /opt/couchdb/bin/couchdb"

# Crear el fichero 'myhosts'
cat /etc/hosts > myhosts
echo "193.144.50.38 opentsdb" >> myhosts
echo "127.0.0.1 couchdb" >> myhosts
echo "127.0.0.1 orchestrator" >> myhosts
echo "10.10.255.232 host0" >> myhosts

# Levantar el contenedor de SC
apptainer instance start --hostname sc --bind /home/jonatan.enes/myhosts:/etc/hosts sc.sif sc

# Arrancar el Orquestador y configurar el entorno
tmux new -s "Orchestrator" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/orchestrator/start.sh"
apptainer exec instance://sc bash ServerlessContainers/conf/create_basics.sh
apptainer exec instance://sc bash ServerlessContainers/conf/subscribe_all.sh

# Arrancar los otros servicios
tmux new -s "Guardian" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/guardian/start.sh"
tmux new -s "Scaler" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/scaler/start.sh"
tmux new -s "DatabaseSnapshoter" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/database_snapshoter/start.sh"
tmux new -s "StructuresSnapshoter" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/structure_snapshoter/start.sh"
tmux new -s "Refeeder" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/refeeder/start.sh"
tmux new -s "CreditManager" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/credit_manager/start.sh"

# Activar el escalado
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/activate_rule.sh default "CpuRescaleUp"
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/activate_rule.sh default "CpuRescaleDown"

apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Structures/set_to_guarded.sh cont0
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Structures/set_resource_to_guarded.sh cont0 cpu

# Configurar GRC
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_rpc_ip.sh "193.144.50.38"


apptainer exec instance://sc bash ServerlessContainers/conf/desubscribe_all.sh
apptainer exec instance://sc bash ServerlessContainers/conf/Orchestrator/desubscribe_users.sh

# Descarga la imagen de minio y despliegalo
apptainer pull docker://quay.io/minio/minio
mkdir /scratch2/minio-data/
apptainer instance start --hostname minio --bind /scratch2/minio-data:/data minio_latest.sif minio
tmux new -s "Minio" "apptainer exec instance://minio /opt/bin/minio server /data/"

# Arranca el contenedor con GRC y dale crédito al user0
apptainer instance start --hostname grc gridcoin.sif grc
apptainer exec instance://grc bash gridcoin-run.sh listaccounts
apptainer exec instance://grc bash gridcoin-run.sh move sink user0 5


