scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/vars.sh

file=$(echo $1 | sed "s/.txt//g")
num_core=$(echo $file | cut -d "-" -f 1)
runtime=$(echo $file | cut -d "-" -f 2)
echo "Will run a stress load with ${num_core} cores for ${runtime} seconds"
echo "Moving the file from input to processing"
mc mv myminio/stress/input/$1 myminio/stress/processing/$1
echo "Running the load now"
sudo apptainer exec instance://${CONT_NAME} stress -c ${num_core} -t ${runtime}
echo "Moving the file from processing to output"
mc mv myminio/stress/processing/$1 myminio/stress/output/$1
