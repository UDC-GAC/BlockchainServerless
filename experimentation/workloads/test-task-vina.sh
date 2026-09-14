scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
   #mc cp /share/store/jonatan.enes/data/vina/1iep_receptor.pdbqt myminio/vina/staging/
   myecho "This load does not load anything in staging dir"
}

#function generate_task {
#  # First parameter is the ligand ID
#  #
#  # Second parameter is the exhaustivity value, from 32 to 64.
#  # It modulates the length of the parallel phase, 32 can be about 10 seconds, 64 up to 40
#  #
#  # Third parameter is the npts, from 56 to 128.
#  # It modulates the length of the sequential phase, 56 is almost instant, 128 up to 70 seconds
#
#  data_path="BlockchainServerless/usage/tasks/vina/"
#  echo "EXH=$2" > ${data_path}/vina_docking_$1/config.env
#  echo "NPTS=$3" >> ${data_path}/vina_docking_$1/config.env
#  zipfolder="${data_path}/vina_docking_$1"
#  zipfile="vina_docking_$1_$2.$3.zip"
#  (cd "$zipfolder" && zip -j -r "../$zipfile" .)
#  mycopy ${data_path}/$zipfile "input"
#}

function generate_task {
    local ligand_num="$1"
    local parallel="$2"  # short | medium | large  -> exhaustiveness
    local serial="$3"    # short | medium | large  -> npts


    local npts exh

    case "${serial}" in
        short)  npts=80  ;;
        medium) npts=100 ;;
        large)  npts=128 ;;
    esac

    case "${parallel}" in
        short)  exh=32  ;;
        medium) exh=64  ;;
        large)  exh=128 ;;
    esac

    data_path="BlockchainServerless/usage/tasks/vina/"
    echo "EXH=$exh" > ${data_path}/vina_docking_$1/config.env
    echo "NPTS=$npts" >> ${data_path}/vina_docking_$1/config.env
    zipfolder="${data_path}/vina_docking_$1"
    zipfile="vina_docking_$1_$exh.$npts.zip"
    (cd "$zipfolder" && zip -j -r "../$zipfile" .)
    mycopy ${data_path}/$zipfile "input"
}


#function generate_load {
#    generate_task "${VINA_LIGAND_NUM}" "short" "short"
#    generate_task "${VINA_LIGAND_NUM}" "short" "medium"
#    generate_task "${VINA_LIGAND_NUM}" "short" "large"
#    generate_task "${VINA_LIGAND_NUM}" "medium" "short"
#    generate_task "${VINA_LIGAND_NUM}" "medium" "medium"
#    generate_task "${VINA_LIGAND_NUM}" "medium" "large"
#    generate_task "${VINA_LIGAND_NUM}" "large" "medium"
#    sleep_time=1200
#    myecho "Waiting for the load to finish (${sleep_time} seconds)"
#    sleep ${sleep_time}
#}

function generate_load {
    generate_task "03" "short" "short"
    generate_task "03" "short" "medium"
    generate_task "03" "short" "large"
    generate_task "03" "medium" "short"
    generate_task "03" "medium" "medium"
    sleep_time=400
    myecho "Waiting for the load to finish (${sleep_time} seconds)"
    sleep ${sleep_time}

    generate_task "10" "medium" "large"
    generate_task "10" "large" "large"
    sleep_time=600
    myecho "Waiting for the load to finish (${sleep_time} seconds)"
    sleep ${sleep_time}

    sleep 400

    generate_task "06" "short" "large"
    generate_task "06" "medium" "short"
    generate_task "06" "medium" "medium"
    sleep_time=400
    myecho "Waiting for the load to finish (${sleep_time} seconds)"
    sleep ${sleep_time}

}

function configure_rules {
  echo "Configuring Rules"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 200
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown down 14
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleUp down 10
}

export -f generate_load
export -f load_staging_data
export -f configure_rules

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/common.sh

export CONT_MAX_CPU=600
export CONT_BOUNDARY_CPU=50
export LOAD_NAME="vina"
export LOAD_BUCKET="myminio/${LOAD_NAME}"
export TIMEOUT=10

#export VINA_LIGAND_NUM="01"
#export MIN_BALANCE="0"
#export MAX_DEBT="-0.5"
#export START_CREDIT=2
#export POLICY="greedy"
#export exp_name="check_task_vina"
#setup_exp
#run_simple_exp

export CONT_MAX_CPU=1800
export CONT_BOUNDARY_CPU=50
export LOAD_NAME="vina"
export LOAD_BUCKET="myminio/${LOAD_NAME}"
export TIMEOUT=10
export MIN_BALANCE="0"
export MAX_DEBT="-0.5"
export START_CREDIT=2
export POLICY="greedy"
export exp_name="check_task_vina_3"
setup_exp
run_simple_exp

#export VINA_LIGAND_NUM="01"
#for VINA_LIGAND_NUM in {20..42}; do
#  export MIN_BALANCE="0"
#  export MAX_DEBT="-0.5"
#  export START_CREDIT=10
#  export POLICY="greedy"
#  export exp_name="vina_${VINA_LIGAND_NUM}"
#  setup_exp
#  run_simple_exp
#done