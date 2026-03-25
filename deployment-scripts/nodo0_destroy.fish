#!/usr/bin/fish


source BlockchainServerless/scripts/exp-vars.sh

# Borrar el fichero 'myhosts'
rm myhosts

# Parar el contenedor de SC
apptainer instance stop sc

# Parar el contenedor con GRC
apptainer instance stop grc

# Borrar el script para cambiar permisos
rm -f change_cgroupsv1_permissions.py

# Parar el Node Scaler
tmux kill-session -t "NODE_SCALER"

# parar el script baseline
tmux kill-session -t "ts_baseline"

exit 0
