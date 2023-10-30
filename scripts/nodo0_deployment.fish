#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 0', el nodo que se use para
# ejecutar las cargas experimentales propiamente

# Tambien se pondrán aquí los comandos comunes a cualquier nodo de experimentación

# Clonar BDWatchdog en el home de Pluton
git clone https://github.com/UDC-GAC/BDWatchdog.git
sed -i 's/opentsdb/193.144.50.38/g' BDWatchdog/services_config.yml

# Clonar Serverless Containers en el home de Pluton, la rama de experimentacion blockchain
git clone -b blockchain-experiments https://github.com/UDC-GAC/ServerlessContainers
sed -i 's/lxc/apptainer/g' ServerlessContainers/services_config.yml

# Construir los contenedores
apptainer build --force base.sif base.def
apptainer build --force experiment.sif experiment.def


# Descargar el script de Oscar para cambiar permisos
wget https://raw.githubusercontent.com/UDC-GAC/ServerlessYARN/master/ansible/provisioning/scripts/change_cgroupsv1_permissions.py

# Arrancar el contenedor de experimentacion
bash start_container.sh

# Arrancar el Node Scaler
tmux new -s "NODE_SCALER" "source ServerlessContainers/set_pythonpath.sh && python3 ServerlessContainers/src/NodeRescaler/NodeRescaler.py"

# Descarga el cliente de minio y configuralo
curl https://dl.min.io/client/mc/release/linux-amd64/mc -o .local/bin/mc
chmod +x .local/bin/mc
mc alias set 'myminio' 'http://10.10.255.231:9000' 'minioadmin' 'minioadmin'
mc admin info myminio

# Crear buckets, directorios y probar
mc mb myminio/test
mc cp base.sif myminio/test/test.sif
mc mb myminio/gatk/sample/input
mc mb myminio/gatk/sample/output
mc mb myminio/gatk/identify/input
mc mb myminio/gatk/identify/output
mc mb myminio/functions/gif/input
mc mb myminio/functions/gif/output
mc mb myminio/functions/transcode/input
mc mb myminio/functions/transcode/output





