scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
  myecho "This load does not load anything in staging dir"
}

function generate_load {
  #  echo "Generate the tasks"
  #  LOAD="0.1-150" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="1.2-100" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="2.1-100" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="3.3-200" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="4.1-100" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="5.2-100" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="6.1-50" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  echo "Waiting"
  #  sleep 810
  #  LOAD="7.2-200" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  echo "Waiting"
  #  sleep 210

  #  LOAD="0.1-60" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="1.1-60" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="2.1-60" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="3.1-60" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="4.1-60" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="5.1-60" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  LOAD="6.1-60" && touch $LOAD.txt && mc mv $LOAD.txt myminio/stress/input
  #  myecho "Waiting"
  #  sleep 430

  #  LD="0.1-100" && touch $LD.txt && mc mv $LD.txt myminio/stress/input
  #  LD="1.2-100" && touch $LD.txt && mc mv $LD.txt myminio/stress/input
  #  myecho "Waiting"
  #  sleep 210

  LD="0.1-50" && touch $LD.txt && mycopy $LD.txt "input"
  myecho "Waiting"
  sleep 60
}

export -f generate_load
export -f load_staging_data

export LOAD_NAME="stress"
export TIMEOUT=45
export MIN_BALANCE=1
export MAX_DEBT="-1"
export START_CREDIT=2

bash ${scriptDir}/common.sh