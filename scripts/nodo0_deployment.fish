#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 0', el nodo que se use para
# ejecutar las cargas experimentales propiamente

# Tambien se pondrán aquí los comandos comunes a cualquier nodo de experimentación

# Clonar BDWatchdog en el home de Pluton
git clone https://github.com/UDC-GAC/BDWatchdog.git
sed -i 's/opentsdb/193.144.50.38/g' BDWatchdog/services_config.yml

# Clonar Serverless Containers en el home de Pluton, la rama de experimentacion blockchain
#git clone -b blockchain-experiments https://github.com/UDC-GAC/ServerlessContainers

# Construir los contenedores de HOST_0
apptainer build --force base.sif BlockchainServerless/containers/base.def
apptainer build --force experiment.sif BlockchainServerless/containers/experiment.def

# Construir los contenedores de HOST_1
apptainer build --force couchdb.sif BlockchainServerless/containers/my_couchdb.def
apptainer build --force sc.sif BlockchainServerless/containers/sc.def
apptainer build --force gridcoin.sif BlockchainServerless/containers/gridcoin.def

# Levantar el contenedor de SC
apptainer instance start --hostname sc --bind /home/jonatan.enes/myhosts:/etc/hosts sc.sif sc

# Descargar el script de Oscar para cambiar permisos
wget https://raw.githubusercontent.com/UDC-GAC/ServerlessYARN/master/ansible/provisioning/scripts/change_cgroupsv1_permissions.py

# Arrancar el Node Scaler
tmux new -s "NODE_SCALER" "source ServerlessContainers/set_pythonpath.sh && python3 ServerlessContainers/src/NodeRescaler/NodeRescaler.py"

# Descarga el cliente de minio y configuralo
curl https://dl.min.io/client/mc/release/linux-amd64/mc -o .local/bin/mc
chmod +x .local/bin/mc
mc alias set 'myminio' "http://$HOST_1:9000" 'minioadmin' 'minioadmin'
mc admin info myminio

# Crear buckets, directorios y probar
mc mb myminio/test
mc cp base.sif myminio/test/test.sif
mc mb myminio/gatk/sample/input
mc mb myminio/gatk/sample/processing
mc mb myminio/gatk/sample/output
mc mb myminio/functions/gif/input
mc mb myminio/functions/gif/processing
mc mb myminio/functions/gif/output
mc mb myminio/stress/input
mc mb myminio/stress/processing
mc mb myminio/stress/output

# Arrancar el manager

############################################




sleep 10
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_test.py start exp_test test0 --push --username root
sleep 20
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_test.py end exp_test test0 --push --username root
sleep 10
python3 BDWatchdog/TimestampsSnitch/src/timestamping/signal_experiment.py end exp_test --push --username root




