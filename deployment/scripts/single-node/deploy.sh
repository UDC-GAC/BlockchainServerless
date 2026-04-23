export MONGODB_IP="193.144.50.38"
export COUCHDB_DATA="./couchdb-data"
export MINIO_DATA="./minio-data"

export INSTALL_PATH="/home/jonatan.enes/BlockchainServerless"

# Clone the BDWatchdog framework, needed by ServelessContainers
git clone https://github.com/UDC-GAC/BDWatchdog.git
sed -i 's/opentsdb/193.144.50.38/g' BDWatchdog/services_config.yml
sed -i 's/POST_DOC_BUFFER_TIMEOUT=10/POST_DOC_BUFFER_TIMEOUT=5/g' BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh

# Clone Serverless Containers, the specific branch used for blockchain experiments
git clone -b blockchain-experiments https://github.com/UDC-GAC/ServerlessContainers


# Build the base container
CONT_IMG_PATH=${INSTALL_PATH}/deployment/containers
apptainer build --force base.sif ${CONT_IMG_PATH}/base.def

# Build the auxiliar containers
apptainer build --force couchdb.sif ${CONT_IMG_PATH}/my_couchdb.def
apptainer build --force sc.sif ${CONT_IMG_PATH}/sc.def
apptainer build --force gridcoin.sif ${CONT_IMG_PATH}/gridcoin.def

# Download the MinIO container image
apptainer pull docker://quay.io/minio/minio

# Populate the 'myhosts' file, to be used as /etc/hosts inside the containers
cat /etc/hosts > myhosts
echo "193.144.50.38 opentsdb" >> myhosts
echo "127.0.0.1 couchdb" >> myhosts
echo "127.0.0.1 orchestrator" >> myhosts
echo "127.0.0.1 host0" >> myhosts

# Start the container for the ServerlessContainer framework
apptainer instance start --hostname sc --bind myhosts:/etc/hosts sc.sif sc

# Start the container with the Gridcoin scripts
GRC_SCRIPTS_PATH=${INSTALL_PATH}/deployment/scripts/gridcoin
apptainer instance start --hostname grc gridcoin.sif grc
# Set the user's credit to 0
bash ${GRC_SCRIPTS_PATH}/set_user_balance.sh 0
# Check that it works, user credit should be 0
apptainer exec instance://grc bash ${GRC_SCRIPTS_PATH}/gridcoin-run.sh listaccounts

# Download a required script needed to change container permissions
wget https://raw.githubusercontent.com/UDC-GAC/ServerlessYARN/master/ansible/provisioning/scripts/change_cgroups_permissions.py

# Start the Node Scaler microservice
pip3 install --user flask pyyaml
tmux new -d -s "NODE_SCALER" "source ServerlessContainers/set_pythonpath.sh && python3 ServerlessContainers/src/NodeRescaler/NodeRescaler.py"

# Start the StateDatabase from ServerlessContainers using Couchdb
rm -Rf ${COUCHDB_DATA} && mkdir ${COUCHDB_DATA}
apptainer instance start --bind ${COUCHDB_DATA}:/opt/couchdb/data --hostname couchdb couchdb.sif couchdb
tmux new -d -s "Couchdb" "apptainer exec instance://couchdb /opt/couchdb/bin/couchdb"

# Start MinIO
rm -Rf ${MINIO_DATA} &&  mkdir ${MINIO_DATA}
apptainer instance start --hostname minio --bind ${MINIO_DATA}:/data minio_latest.sif minio
tmux new -d -s "Minio" "apptainer exec instance://minio /bin/minio server /data/"

# Start the Orchestrator microservice and configure the basi content
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

# Configurar cliente de MinIO
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
mv mc .local/bin/
mc alias set 'myminio' "http://localhost:9000" 'minioadmin' 'minioadmin'
mc admin info myminio

# Arrancar el ContainerManager
### PENDING FIX
export SCRIPTS_BASE_PATH="/home/jonatan.enes/BlockchainServerless/deployment/scripts/tasks"
export HOST_MINIO="127.0.0.1"
pip3 install --user minio==7.0.0 termcolor
tmux new -d -s "ContainerManager" "source ServerlessContainers/set_pythonpath.sh && python3 BlockchainServerless/deployment/microservices/ContainerManager.py"
### PENDING FIX


# Construir los contenedores de experimentación
apptainer build --force stress.sif ${INSTALL_PATH}/usage/containers/stress.def

