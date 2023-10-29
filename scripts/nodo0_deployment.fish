#!/usr/bin/fish

# Estos son los comandos a ejecutar en el 'nodo 0', el nodo que se use para
# ejecutar las cargas experimentales propiamente

# Tambien se pondrán aquí los comandos comunes a cualquier nodo de experimentación

# Clonar BDWatchdog en el home de Pluton
git clone https://github.com/UDC-GAC/BDWatchdog.git

# Clonar Serverless Containers en el home de Pluton, la rama de experimentacion blockchain
git clone -b blockchain-experiments https://github.com/UDC-GAC/ServerlessContainers
sed -i 's/lxc/apptainer/g' ServerlessContainers/services_config.yml

# Construir los contenedores
apptainer build --force base.sif base.def

# Arrancar el contenedor de experimentacion
set -gx CONT_NAME "cont0"
sudo apptainer instance start --hostname {$CONT_NAME} base.sif {$CONT_NAME}

# Descargar el script de Oscar para cambiar permisos
wget https://raw.githubusercontent.com/UDC-GAC/ServerlessYARN/master/ansible/provisioning/scripts/change_cgroupsv1_permissions.py
python3 change_cgroupsv1_permissions.py apptainer singularity {$CONT_NAME}

# Arrancar el Node Scaler
source ServerlessContainers/set_pythonpath.fish
tmux new -s "NODE_SCALER" "python3 ServerlessContainers/src/NodeRescaler/NodeRescaler.py"


# Arrancar el MetricsFeeder en el contenedor de experimentos



