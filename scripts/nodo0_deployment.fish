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

# Arrancar el contenedor de experimentacion
set -gx CONT_NAME "cont0"
touch cgroups_file.toml
sudo apptainer instance start --hostname {$CONT_NAME} --apply-cgroups cgroups_file.toml experiment.sif {$CONT_NAME}

# Descargar el script de Oscar para cambiar permisos
wget https://raw.githubusercontent.com/UDC-GAC/ServerlessYARN/master/ansible/provisioning/scripts/change_cgroupsv1_permissions.py
python3 change_cgroupsv1_permissions.py apptainer singularity {$CONT_NAME}

# Arrancar el Node Scaler
source ServerlessContainers/set_pythonpath.fish
tmux new -s "NODE_SCALER" "python3 ServerlessContainers/src/NodeRescaler/NodeRescaler.py"

# Arrancar el MetricsFeeder en el contenedor de experimentos
tmux new -s "ATOP" "sudo apptainer exec instance://cont0 bash /home/jonatan.enes/BDWatchdog/MetricsFeeder/scripts/run_atop_stream.sh"


