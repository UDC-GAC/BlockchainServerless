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