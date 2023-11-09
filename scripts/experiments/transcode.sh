scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
  myecho "This load does not load anything in staging dir"
}

function generate_load {
  for run in {1..6}; do
    mycopy animals/frogs/${run}/frog${run}-360.mp4 "input"
    mycopy animals/frogs/${run}/frog${run}-540.mp4 "input"
    mycopy animals/frogs/${run}/frog${run}-720.mp4 "input"
    mycopy animals/frogs/${run}/frog${run}-1080.mp4 "input"
  done
  # Frogs take around 2100 seconds (35m) in non-serverless and 2180 in serverless

  myecho "Waiting"
  sleep 2600

  #myecho "Press any key when tasks are done"
  #read -p "Press enter to continue"
}


export -f generate_load
export -f load_staging_data

export LOAD_NAME="transcode"
export TIMEOUT=45
export MIN_BALANCE=1
export MAX_DEBT="-1"
export START_CREDIT=120

bash ${scriptDir}/common.sh