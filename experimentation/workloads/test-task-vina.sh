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
    local serial="$2"    # short | medium | large  -> npts
    local parallel="$3"  # short | medium | large  -> exhaustiveness

    local npts exh

    case "${serial}" in
        short)  npts=80  ;;
        medium) npts=100 ;;
        long)  npts=128 ;;
    esac

    case "${parallel}" in
        short)  exh=32  ;;
        medium) exh=64  ;;
        long)  exh=128 ;;
    esac

    data_path="BlockchainServerless/usage/tasks/vina/"
    echo "EXH=$exh" > ${data_path}/vina_docking_$1/config.env
    echo "NPTS=$npts" >> ${data_path}/vina_docking_$1/config.env
    zipfolder="${data_path}/vina_docking_$1"
    zipfile="vina_docking_$1_$exh.$npts.zip"
    (cd "$zipfolder" && zip -j -r "../$zipfile" .)
    mycopy ${data_path}/$zipfile "input"
}

function generate_load {

    generate_task "14" "long" "medium"
    generate_task "04" "short" "short"
    generate_task "04" "medium" "short"
    generate_task "14" "long" "long"
    generate_task "17" "long" "long"
    generate_task "04" "short" "medium"
    generate_task "04" "medium" "medium"
    generate_task "06" "long" "short"
    generate_task "06" "short" "medium"
    generate_task "04" "long" "short"
    generate_task "06" "medium" "medium"
    sleep_time=1500
    myecho "Waiting for the load to finish (${sleep_time} seconds)"
    sleep ${sleep_time}
}


#function generate_load {
#
#    generate_task "14" "long" "medium"
#    generate_task "14" "long" "long"
#    generate_task "17" "long" "long"
#    sleep_time=800
#    myecho "Waiting for the load to finish (${sleep_time} seconds)"
#    sleep ${sleep_time}
#
#    generate_task "04" "short" "short"
#    generate_task "04" "medium" "short"
#    generate_task "04" "long" "short"
#    generate_task "04" "short" "medium"
#    generate_task "04" "medium" "medium"
#    sleep_time=800
#    myecho "Waiting for the load to finish (${sleep_time} seconds)"
#    sleep ${sleep_time}
#
#    generate_task "06" "long" "short"
#    generate_task "06" "short" "medium"
#    generate_task "06" "medium" "medium"
#    sleep_time=400
#    myecho "Waiting for the load to finish (${sleep_time} seconds)"
#    sleep ${sleep_time}
#}
#
#function set_responsiveness {
#   case "${responsiveness}" in
#        low)
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown down 12
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown up 0
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleUp down 2
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleUp up 6;;
#        medium)
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown down 6
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown up 0
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleUp down 6
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleUp up 4;;
#        high)
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown down 4
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown up 1
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleUp down 10
#          apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleUp up 2;;
#    esac
#}
#
#
#function set_benevolence {
#     case "${benevolence}" in
#        low) apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 100 ;;
#        medium) apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 200;;
#        high)  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 300 ;;
#    esac
#}
#
#function configure_rules {
#    echo "Configuring Rules"
#    set_responsiveness
#    set_benevolence
#}


function configure_rules {
  myecho "Configuring Rules"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 200
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown down 4 # default is 6
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/set_event_timeout.sh 60                            # default is 80
}

function set-cont-template-cpu-current {
    case "${startup_resources}" in
        min) set-cont-template-cpu-current-to-min;;
        halfmax) set-cont-template-cpu-current-to-halfmax;;
        max) set-cont-template-cpu-current-to-max;;
    esac
}

export -f generate_load
export -f load_staging_data
export -f configure_rules

export scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
source ${scriptDir}/common.sh

#export CONT_MAX_CPU=600
#export CONT_BOUNDARY_CPU=50
#export LOAD_NAME="vina"
#export LOAD_BUCKET="myminio/${LOAD_NAME}"
#export TIMEOUT=10

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
export START_CREDIT=20
export POLICY="greedy"

export exp_name="2.vina_baseline"
setup_exp
empty_bucket
signal_exp "start"
run_noserv_noacct
signal_exp "end"
#
#export benevolence="high"
#export responsiveness="high"
#export startup_resources="min"
#export exp_name="vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="medium"
#export responsiveness="high"
#export startup_resources="min"
#export exp_name="vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="high"
#export responsiveness="low"
#export startup_resources="min"
#export exp_name="vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="high"
#export responsiveness="low"
#export startup_resources="halfmax"
#export exp_name="vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="medium"
#export responsiveness="medium"
#export startup_resources="halfmax"
#export exp_name="vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"


#export benevolence="high"
#export responsiveness="high"
#export startup_resources="min"
#export exp_name="2.vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="medium"
#export responsiveness="high"
#export startup_resources="min"
#export exp_name="2.vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="high"
#export responsiveness="low"
#export startup_resources="min"
#export exp_name="2.vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="high"
#export responsiveness="low"
#export startup_resources="halfmax"
#export exp_name="2.vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"
#
#export benevolence="medium"
#export responsiveness="medium"
#export startup_resources="halfmax"
#export exp_name="2.vina_st[${startup_resources}]_resp[${responsiveness}]_ben[${benevolence}]"
#setup_exp
#empty_bucket
#signal_exp "start"
#run_serv_acct
#signal_exp "end"

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