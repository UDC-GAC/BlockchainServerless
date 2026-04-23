if [ -z "$1" ]
then
      echo "RPC command was not provided"
      exit 1
fi

gridcoinresearchd \
  -rpcconnect=${IP} \
  -rpcport=${PORT} \
  -rpcuser=${USER} \
  -rpcpassword=${PASS} "$@"
  
  
# Comandos ejemplos que se pueden ejecutar
#bash gridcoin-run.sh listaccounts
#bash gridcoin-run.sh move user0 user1 10
#bash gridcoin-run.sh getbalancedetail
#bash gridcoin-run.sh getwalletinfo
#bash gridcoin-run.sh getaddressesbyaccount sink
#bash gridcoin-run.sh getaccountaddress sink
#bash gridcoin-run.sh getbalance
#bash gridcoin-run.sh getbalance sink
#bash gridcoin-run.sh listtransactions
#bash gridcoin-run.sh sendfrom sink SFwx7tNoMDwDLuLgdhc2Ht9JEcPAbr2CjN 10
