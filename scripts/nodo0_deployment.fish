#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 0', el nodo que se use para
# ejecutar las cargas experimentales propiamente

# Tambien se pondrán aquí los comandos comunes a cualquier nodo de experimentación

echo "Este script aun no soporta la ejecución automatizada"
exit 0

# Configurar las variables de entorno
vim BlockchainServerless/scripts/exp-vars.sh
vim BlockchainServerless/scripts/exp-vars.fish

# Exportarlas
source BlockchainServerless/scripts/exp-vars.sh

# Clonar BDWatchdog en el home de Pluton
git clone https://github.com/UDC-GAC/BDWatchdog.git
sed -i 's/opentsdb/193.144.50.38/g' BDWatchdog/services_config.yml
sed -i 's/POST_DOC_BUFFER_TIMEOUT=10/POST_DOC_BUFFER_TIMEOUT=5/g' BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh

# Clonar Serverless Containers en el home de Pluton, la rama de experimentacion blockchain
#git clone -b blockchain-experiments https://github.com/UDC-GAC/ServerlessContainers

# Construir el contenedor base
apptainer build --force base.sif BlockchainServerless/containers/base.def

# Construir los contenedores de experimentación
apptainer build --force stress.sif BlockchainServerless/containers/stress.def
apptainer build --force gatk.sif BlockchainServerless/containers/gatk.def
apptainer build --force functions.sif BlockchainServerless/containers/functions.def

# Construir los contenedores auxiliares
apptainer build --force couchdb.sif BlockchainServerless/containers/my_couchdb.def
apptainer build --force sc.sif BlockchainServerless/containers/sc.def
apptainer build --force gridcoin.sif BlockchainServerless/containers/gridcoin.def

# Descargar la imagen de MinIO
apptainer pull docker://quay.io/minio/minio

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
bash BlockchainServerless/scripts/gridcoin/set_user_balance.sh 0
apptainer exec instance://grc bash BlockchainServerless/scripts/gridcoin/gridcoin-run.sh listaccounts

# Descargar el script de Oscar para cambiar permisos
wget https://raw.githubusercontent.com/UDC-GAC/ServerlessYARN/master/ansible/provisioning/scripts/change_cgroupsv1_permissions.py

# Arrancar el Node Scaler
tmux new -d -s "NODE_SCALER" "source ServerlessContainers/set_pythonpath.sh && python3 ServerlessContainers/src/NodeRescaler/NodeRescaler.py"

# Arrancar el script que manda el baseline (0) de serie temporal del contenedor
tmux new -d -s "ts_baseline" "watch -n 5 bash BlockchainServerless/scripts/send_baseline.sh"

# Configurar cliente de MinIO
mc alias set 'myminio' "http://$HOST_1:9000" 'minioadmin' 'minioadmin'
mc admin info myminio

exit 0

############################################

mc mb myminio/test
mc cp base.sif myminio/test/test.sif
mc mb myminio/gatk/sample/input
mc mb myminio/gatk/sample/processing
mc mb myminio/gatk/sample/output
mc mb myminio/gif/input
mc mb myminio/gif/processing
mc mb myminio/gif/output
mc mb myminio/gif/utils


# Arrancar el manager
