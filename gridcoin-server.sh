exit 0

# Para configurar el servidor es
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
gridcoinresearchd -rpcconnect=192.168.51.100 -rpcport=9090 -rpcuser=gridcoinrpc -rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV listaccounts
gridcoinresearchd -rpcconnect=192.168.51.100 -rpcport=9090 -rpcuser=gridcoinrpc -rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV move user0 user1 10
gridcoinresearchd -rpcconnect=192.168.51.100 -rpcport=9090 -rpcuser=gridcoinrpc -rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV getbalancedetail
gridcoinresearchd -rpcconnect=192.168.51.100 -rpcport=9090 -rpcuser=gridcoinrpc -rpcpassword=Bt2oEfVgnMGqvB26UapLERmDu5bvULKr9SPvPBkMkMSV getwalletinfo


