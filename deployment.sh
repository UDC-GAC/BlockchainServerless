exit 0 

## EN SERVER 1 ###
# Cambiar los recursos 
cd AutoServerlessWeb/ansible/provisioning
vim config/config.yml

# Personalizar la imagen base de apptainer
vim ansible/provisioning/templates/ubuntu_container.def

## EN SC-SERVER ##
vagrant ssh

SERV_INST="/vagrant/ServerlessContainers/"

# Cambiar en el fichero 'hosts'
sudo vim /etc/hosts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
127.0.0.1 localhost couchdb orchestrator opentsdb
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Instalar todo
cd /vagrant/ansible/provisioning/scripts
python3 load_inventory_from_conf.py
bash start_all.sh

# Arrancar BDWatchdog
source /etc/environment
cd /home/vagrant/AutoServerlessWeb_install/BDWatchdog/deployment/metrics
bash start.sh

# Hay que instalar algunos paquetes
sudo apt install jq

# En los nodos clientes, hay que arrancar el node_scaler como root
ssh host0
tmux kill-session -t "node_scaler"
killall gunicorn3
sudo su
cd /home/vagrant/AutoServerlessWeb_install/ServerlessContainers
bash scripts/services/node_scaler/start_tmux.sh 
exit
exit

# Volver a sc-server
# Hay que arrancar el orquestador
cd ${SERV_INST}
bash scripts/services/orchestrator/start_tmux.sh
tmux ls


# Hay que adaptar toda la configuracion de la infraestructura
# HOSTS -> host0
# CONTAINERS -> host0-cont0
# Este fichero no se sincroniza desde local a remoto, pero se puede editar en local en PyCharm y que al guardar se mande
vim conf/Orchestrator/layout.json

# Hay que crear las métricas de Serverless en BDWatchdog
cd /home/vagrant/AutoServerlessWeb_install/BDWatchdog/deployment/metrics/opentsdb
bash ${SERV_INST}/scripts/databases/create-rescaler-opentsdb-metrics.sh

# Hay que crear las tablas del framework de Serverless y subscribir todo
cd ${SERV_INST}
bash conf/create_basics.sh
bash conf/subscribe-all.sh


# Comprobaciones en local
/usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" "http://192.168.56.200:4242/" # OpenTSDB 
/usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" "http://192.168.56.200/" # Interfaz web BDWatchdog
/usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" "http://192.168.56.200:50070/" # Namenode HDFS
/usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" "http://192.168.56.201:8000/container/" # Node Scaler Host0
/usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" "http://192.168.56.200:5000/structure/" # Orquestador


# Hay que arrancar los servicios Serverless
bash scripts/services/start_services.sh 

# Para probar activar el Guardian
bash scripts/orchestrator/Guardian/activate.sh 
bash scripts/orchestrator/Structures/set_to_guarded.sh host0-cont0
bash scripts/orchestrator/Structures/set_resource_to_guarded.sh host0-cont0 cpu

# Poner como 'guardable' los recursos cpu y mem
bash scripts/orchestrator/Guardian/set_guardable_resources.sh cpu

# Activar regla
bash scripts/orchestrator/Rules/activate_rule.sh default CpuRescaleDown
bash scripts/orchestrator/Rules/activate_rule.sh default CpuRescaleUp
bash scripts/orchestrator/Rules/activate_rule.sh benevolent CpuRescaleDown
bash scripts/orchestrator/Rules/activate_rule.sh benevolent CpuRescaleUp
bash scripts/orchestrator/Rules/activate_rule.sh strict CpuRescaleDown
bash scripts/orchestrator/Rules/activate_rule.sh strict CpuRescaleUp

# Activar el Scaler
bash scripts/orchestrator/Scaler/activate.sh



#### COMANDOS PARA APPTAINER ####
# Para conectarse a una instancia
apptainer exec instance://host0-cont0 bash
# Modificar la imagen base
vim /vagrant/ansible/provisioning/templates/ubuntu_container.def


#### COMANDOS PARA LXC ####
ssh host0
cd /vagrant
lxc file push -r BDWatchdog/ host0-cont0/home/vagrant/AutoServerlessWeb_install


lxc exec host0-cont0
echo "192.168.56.200 opentsdb" >> /etc/hosts
cd /home/vagrant/AutoServerlessWeb_install/BDWatchdog/
bash MetricsFeeder/scripts/run_atop_stream_tmux.sh
apt update
apt install stress


~~~~~~~~~~~~ NOTAS ~~~~~~~~~~~~~

sudo add-apt-repository ppa:gridcoin/gridcoin-stable
sudo apt update
sudo apt install gridcoinresearchd
gridcoinresearchd -rpcconnect=192.168.51.100 -rpcport=9090 -rpcuser=gridcoinrpc -rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV listaccounts

