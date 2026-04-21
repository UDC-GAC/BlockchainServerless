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
rpcallowip=192.168.51.100
rpcallowip=192.168.51.240
rpcallowip=192.168.10.1
rpcallowip=192.168.10.10
rpcallowip=192.168.10.16
rpcallowip=127.0.0.1
rpcallowip=193.144.50.12
rpcallowip=192.168.40.2
rpcport=9090
rpcuser=gridcoinrpc
rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Para instalar el servidor es
sudo add-apt-repository ppa:gridcoin/gridcoin-stable
sudo apt update
sudo apt install gridcoinresearchd

# Para arrancar el servidor es, HAY QUE ESPERAR UNOS SEGUNDOS POR LA SINCRONIZACIÓN DE BLOQUES
gridcoinresearchd -debug -printtoconsole

vim gridcoin-run.sh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ -z "$1" ]
then
      echo "RPC command was not provided"
      exit 1
fi
gridcoinresearchd -rpcconnect=192.168.51.100 -rpcport=9090 -rpcuser=gridcoinrpc -rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV "$@"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Comandos ejemplos que se pueden ejecutar
bash gridcoin-run.sh listaccounts
bash gridcoin-run.sh move user0 user1 10
bash gridcoin-run.sh getbalancedetail
bash gridcoin-run.sh getwalletinfo
bash gridcoin-run.sh getaddressesbyaccount sink
bash gridcoin-run.sh getaccountaddress sink
bash gridcoin-run.sh getbalance
bash gridcoin-run.sh getbalance sink
bash gridcoin-run.sh listtransactions
bash gridcoin-run.sh sendfrom sink SFwx7tNoMDwDLuLgdhc2Ht9JEcPAbr2CjN 10

# La snapshot de la blockchain esta en
# https://download.gridcoin.us/download/downloadstake/signed/snapshot.zip