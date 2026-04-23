exit 0

# Commands to install the Gridcoin node server
sudo add-apt-repository ppa:gridcoin/gridcoin-stable
sudo apt update
sudo apt install gridcoinresearchd

# Configure the node before starting it
#
# Help for the configuration parameters
# https://gridcoin.us/wiki/config-file
#
vim /root/.GridcoinResearch/gridcoinresearch.conf
# Insert the next text ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Start the server, WAIT A FEW SECONDS UNTIL THE CHAIN IS SYNCHRONIZED
gridcoinresearchd -debug -printtoconsole


# The blockchain snapshot, to be used to avoid synchronization time, is also available at
# https://download.gridcoin.us/download/downloadstake/signed/snapshot.zip
