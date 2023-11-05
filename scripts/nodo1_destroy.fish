#!/usr/bin/fish

source BlockchainServerless/scripts/exp-vars.fish

# Tumbar la StateDatabase (Couchdb)
apptainer instance stop couchdb
rm -Rf {$COUCHDB_DATA}

# Tumbar el contenedor de SC
apptainer instance stop sc

# Parar MinIO
apptainer instance stop minio
rm -Rf {$MINIO_DATA}

rm credit_manager.log database_snapshoter.log guardian.log refeeder.log scaler.log structures_snapshoter.log

exit 0

#####################
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Structures/set_to_guarded.sh cont0
apptainer exec instance://sc bash ServerlessContainers/conf/desubscribe_all.sh
apptainer exec instance://sc bash ServerlessContainers/conf/Orchestrator/desubscribe_users.sh
apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Users/unrestrict_user_accounting.sh user0

