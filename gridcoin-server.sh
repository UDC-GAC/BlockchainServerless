exit 0

# Para configurar el servidor es
#
# Ayuda para fichero de configuración
# https://gridcoin.us/wiki/config-file
#
vim /root/.GridcoinResearch/gridcoinresearch.conf
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
addnode=addnode-us-central.cycy.me
addnode=ec2-3-81-39-58.compute-1.amazonaws.com
addnode=gridcoin.network
addnode=seeds.gridcoin.ifoggz-network.xyz
addnode=seed.gridcoin.pl
addnode=www.grcpool.com

enableaccounts=1
staking=0

server=1
rpcallowip=192.168.51.1
rpcallowip=192.168.10.10
rpcallowip=192.168.10.16
rpcport=9090
rpcuser=gridcoinrpc
rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Para instalar el servidor es
sudo add-apt-repository ppa:gridcoin/gridcoin-stable
sudo apt update
sudo apt install gridcoinresearchd

# Para arrancar el servidor es, HAY QUE ESPERAR UNOS SEGUNDOS POR LA SINCRONIZACION DE BLOQUES
gridcoinresearchd

# Comandos ejemplos que se pueden ejecutar
bash gridcoin-run.sh listaccounts
bash gridcoin-run.sh move user0 user1 10
bash gridcoin-run.sh getbalancedetail
bash gridcoin-run.sh getwalletinfo

