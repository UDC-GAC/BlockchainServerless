# compute-2-0 -> 10.10.255.233
# compute-2-1 -> 10.10.255.232
# compute-2-2 -> 10.10.255.231
# compute-2-3 -> 10.10.255.230

set -gx HOST_0 10.10.255.233
set -gx HOST_1 10.10.255.232
set -gx COUCHDB_DATA "/scratch2/couchdb-data"
set -gx MINIO_DATA "/scratch2/minio-data"
set -gx MONGODB_IP 193.144.50.38