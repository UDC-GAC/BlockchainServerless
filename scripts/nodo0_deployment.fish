#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 0', el nodo que se use para
# ejecutar las cargas experimentales propiamente

# Tambien se pondrán aquí los comandos comunes a cualquier nodo de experimentación

# Configurar las variables de entorno
vim BlockchainServerless/scripts/exp-vars.sh
vim BlockchainServerless/scripts/exp-vars.fish

# Clonar BDWatchdog en el home de Pluton
git clone https://github.com/UDC-GAC/BDWatchdog.git
sed -i 's/opentsdb/193.144.50.38/g' BDWatchdog/services_config.yml
sed -i 's/POST_DOC_BUFFER_TIMEOUT=10/POST_DOC_BUFFER_TIMEOUT=5/g' BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh

# Clonar Serverless Containers en el home de Pluton, la rama de experimentacion blockchain
#git clone -b blockchain-experiments https://github.com/UDC-GAC/ServerlessContainers

# Construir los contenedores de experimentacion
apptainer build --force base.sif BlockchainServerless/containers/base.def
apptainer build --force experiment.sif BlockchainServerless/containers/experiment.def

# Construir los contenedores auxiliares
apptainer build --force couchdb.sif BlockchainServerless/containers/my_couchdb.def
apptainer build --force sc.sif BlockchainServerless/containers/sc.def
apptainer build --force gridcoin.sif BlockchainServerless/containers/gridcoin.def

# Crear el fichero 'myhosts'
cat /etc/hosts > myhosts
echo "193.144.50.38 opentsdb" >> myhosts
echo "$HOST_1 couchdb" >> myhosts
echo "$HOST_1 orchestrator" >> myhosts
echo "$HOST_0 host0" >> myhosts

# Levantar el contenedor de SC
apptainer instance start --hostname sc --bind /home/jonatan.enes/myhosts:/etc/hosts sc.sif sc

# Arranca el contenedor con GRC y pon crédito del user0 a 0
apptainer instance start --hostname grc gridcoin.sif grc
bash BlockchainServerless/scripts/gridcoin/set_zero_balance.sh
apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh listaccounts


# Descargar el script de Oscar para cambiar permisos
wget https://raw.githubusercontent.com/UDC-GAC/ServerlessYARN/master/ansible/provisioning/scripts/change_cgroupsv1_permissions.py

# Arrancar el Node Scaler
tmux new -s "NODE_SCALER" "source ServerlessContainers/set_pythonpath.sh && python3 ServerlessContainers/src/NodeRescaler/NodeRescaler.py"

# Configurar cliente de MinIO
mc alias set 'myminio' "http://$HOST_1:9000" 'minioadmin' 'minioadmin'
mc admin info myminio

# Crear buckets y directorios
mc mb myminio/stress/input
mc mb myminio/stress/processing
mc mb myminio/stress/output



############################################

mc mb myminio/test
mc cp base.sif myminio/test/test.sif
mc mb myminio/gatk/sample/input
mc mb myminio/gatk/sample/processing
mc mb myminio/gatk/sample/output
mc mb myminio/functions/gif/input
mc mb myminio/functions/gif/processing
mc mb myminio/functions/gif/output


# Arrancar el manager
