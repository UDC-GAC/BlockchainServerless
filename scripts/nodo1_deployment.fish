#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 1', el nodo auxiliar
# usado para levantar el framework de Serverless Containers y cualquier 
# otro programa necesario para la ejecucion de los experimentos

# Levantar la StateDatabase (Couchdb)
rm -Rf {$COUCHDB_DATA} && mkdir {$COUCHDB_DATA}
apptainer instance start --bind {$COUCHDB_DATA}:/opt/couchdb/data --hostname couchdb couchdb.sif couchdb
tmux new -s "Couchdb" "apptainer exec instance://couchdb /opt/couchdb/bin/couchdb"

# Crear el fichero 'myhosts'
cat /etc/hosts > myhosts
echo "193.144.50.38 opentsdb" >> myhosts
echo "$HOST_1 couchdb" >> myhosts
echo "$HOST_1 orchestrator" >> myhosts
echo "$HOST_0 host0" >> myhosts

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
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/set_rpc_ip.sh "193.144.50.38"

# Activar el escalado
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Scaler/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/activate.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/CreditManager/activate.sh

# Descarga la imagen de minio y despliegalo
apptainer pull docker://quay.io/minio/minio
rm -Rf {$MINIO_DATA} &&  mkdir {$MINIO_DATA}
apptainer instance start --hostname minio --bind {$MINIO_DATA}:/data minio_latest.sif minio
tmux new -s "Minio" "apptainer exec instance://minio /opt/bin/minio server /data/"

# Arranca el contenedor con GRC y pon crédito del user0 a 0
apptainer instance start --hostname grc gridcoin.sif grc
bash BlockchainServerless/scripts/gridcoin/set_zero_balance.sh
apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh listaccounts


#####################
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Structures/set_to_guarded.sh cont0
apptainer exec instance://sc bash ServerlessContainers/conf/desubscribe_all.sh
apptainer exec instance://sc bash ServerlessContainers/conf/Orchestrator/desubscribe_users.sh

apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/unrestrict_user_accounting.sh user0

