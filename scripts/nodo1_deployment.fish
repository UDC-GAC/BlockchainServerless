
# Estos son los comandos a ejecutar en el 'nodo 1', el nodo auxiliar
# usado para levantar el framework de Serverless Containers y cualquier 
# otro programa necesario para la ejecucion de los experimentos

# Construir los contenedores
apptainer build --force couchdb.sif my_couchdb.def
apptainer build --force sc.sif sc.def

# Levantar la StateDatabase (Couchdb)
set -gx COUCHDB_DATA "/scratch2/couchdb-data"
rm -Rf {$COUCHDB_DATA}
mkdir /home/jonatan.enes/couchdb-data
apptainer instance start --bind /home/jonatan.enes/couchdb-data:/opt/couchdb/data --hostname couchdb couchdb.sif couchdb

# Crear el fichero 'myhosts'
cat /etc/hosts > myhosts
echo "dante.dec.udc.es opentsdb" >> myhosts
echo "127.0.0.1 couchdb" >> myhosts
echo "127.0.0.1 orchestrator" >> myhosts
echo "compute-2-1 host0" >> myhosts


# Levantar el contenedor de SC
apptainer instance start --hostname sc --bind /home/jonatan.enes/myhosts:/etc/hosts sc.sif sc
tmux new -s "Orchestrator" "apptainer exec instance://sc bash ServerlessContainers/scripts/services/orchestrator/start.sh"

apptainer shell instance://sc

apptainer exec instance://sc bash ServerlessContainers/conf/create_basics.sh
apptainer exec instance://sc bash ServerlessContainers/conf/subscribe_all.sh

~~~~~
fish
cd ServerlessContainers
bash conf/create_basics.sh

~~~

