exit 0 

## EN SERVER 1 ###
# Clonar repo Oscar
cd /home/jonatan/
git clone https://github.com/UDC-GAC/ServerlessYARN


cd /home/jonatan/ServerlessYARN/ansible/provisioning
# Clonar repos
git clone https://github.com/UDC-GAC/bdwatchdog.git
git clone https://github.com/UDC-GAC/ServerlessContainers.git
# Cambiar los recursos, usar el fichero config.yaml del repo
rm config/config.yml
vim config/config.yml


# Si se usa APPTAINER, personalizar la imagen base de apptainer
vim templates/ubuntu_container.def

# Clonar ServerlessContainers en la raiz de vagrant y ponerlo en la rama de nuevas funcionalidades
cd /home/jonatan/ServerlessYARN
git clone https://github.com/UDC-GAC/ServerlessContainers
cd ServerlessContainers
git fetch origin new-features
git checkout new-features
git pull

# Arrancar las VMs
cd /home/jonatan/ServerlessYARN
vagrant up

# Añadir dirección de Opentsdb
sudo vim /etc/hosts
~~~~~~~~
192.168.56.200  sc-server opentsdb
~~~~~~~~

# Conectarse al SC-SERVER
vagrant ssh

## EN SC-SERVER ##

SERV_INST="/vagrant/ServerlessContainers/"

# Cambiar en el fichero 'hosts'
sudo vim /etc/hosts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
127.0.0.1 localhost couchdb orchestrator opentsdb
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Instalar todo dentro de una sesion tmux
cd /vagrant/ansible/provisioning/scripts
tmux
python3 load_inventory_from_conf.py
bash start_all.sh

# Arrancar BDWatchdog
source /etc/environment
cd /home/vagrant/AutoServerlessWeb_install/BDWatchdog/deployment/metrics
bash start.sh

# Hay que instalar algunos paquetes
sudo apt install jq

# En el nodo cliente, hay que arrancar el node_scaler como root
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


# Hay que adaptar toda la configuración de la infraestructura
# HOSTS -> host0
# CONTAINERS -> host0-cont0
# Este fichero no se sincroniza desde local a remoto, pero se puede editar en local en PyCharm y que al guardar se mande
vim conf/layout.json

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
/usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" "http://192.168.56.200:5000/structure/" # Orquestador Estructuras
/usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" "http://192.168.56.200:5000/user/" # Orquestador Usuarios

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
lxc exec host0-cont0 bash
git clone https://github.com/UDC-GAC/BDWAtchdog
echo "192.168.56.200 opentsdb" >> /etc/hosts
cd BDWAtchdog

vim MetricsFeeder/scripts/run_atop_stream.sh
~~
export POST_DOC_BUFFER_TIMEOUT=5
~~
bash MetricsFeeder/scripts/run_atop_stream_tmux.sh
apt update
apt install stress


~~~~~~~~~~~~ NOTAS ~~~~~~~~~~~~~

sudo add-apt-repository ppa:gridcoin/gridcoin-stable
sudo apt update
sudo apt install gridcoinresearchd
gridcoinresearchd -rpcconnect=192.168.51.100 -rpcport=9090 -rpcuser=gridcoinrpc -rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV listaccounts

# Hay que crear las métricas de blockchain
cd /home/vagrant/AutoServerlessWeb_install/BDWatchdog/deployment/metrics/opentsdb
bash ${SERV_INST}/scripts/databases/create-credit-opentsdb-metrics.sh