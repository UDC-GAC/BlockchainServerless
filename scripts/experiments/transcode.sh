scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function load_staging_data {
  myecho "This load does not load anything in staging dir"
}

export exptime=0
function sumtime {
  declare -A serv
  serv["frog1-360"]="47"
  serv["frog1-540"]="91"
  serv["frog1-720"]="83"
  serv["frog1-1080"]="144"
  serv["frog2-360"]="35"
  serv["frog2-540"]="71"
  serv["frog2-720"]="74"
  serv["frog2-1080"]="152"
  serv["frog3-360"]="14"
  serv["frog3-540"]="28"
  serv["frog3-720"]="38"
  serv["frog3-1080"]="79"
  serv["frog4-360"]="46"
  serv["frog4-540"]="90"
  serv["frog4-720"]="149"
  serv["frog4-1080"]="279"
  serv["frog5-360"]="30"
  serv["frog5-540"]="60"
  serv["frog5-720"]="105"
  serv["frog5-1080"]="234"
  serv["frog6-360"]="24"
  serv["frog6-540"]="54"
  serv["frog6-720"]="54"
  serv["frog6-1080"]="95"
  serv["seagull1-360"]="36"
  serv["seagull1-540"]="87"
  serv["seagull1-720"]="96"
  serv["seagull1-1080"]="205"
  serv["seagull2-360"]="15"
  serv["seagull2-540"]="28"
  serv["seagull2-720"]="32"
  serv["seagull2-1080"]="54"
  serv["seagull3-360"]="65"
  serv["seagull3-540"]="136"
  serv["seagull3-720"]="113"
  serv["seagull3-1080"]="204"
  serv["seagull4-360"]="26"
  serv["seagull4-540"]="45"
  serv["seagull4-720"]="49"
  serv["seagull4-1080"]="90"
  serv["seagull5-360"]="55"
  serv["seagull5-540"]="108"
  serv["seagull5-720"]="114"
  serv["seagull5-1080"]="216"
  serv["seagull6-360"]="38"
  serv["seagull6-540"]="78"
  serv["seagull6-720"]="74"
  serv["seagull6-1080"]="125"
  serv["bird1-360"]="44"
  serv["bird1-540"]="82"
  serv["bird1-720"]="85"
  serv["bird1-1080"]="161"
  serv["bird2-360"]="56"
  serv["bird2-540"]="95"
  serv["bird2-720"]="96"
  serv["bird2-1080"]="169"
  serv["bird3-360"]="32"
  serv["bird3-540"]="60"
  serv["bird3-720"]="66"
  serv["bird3-1080"]="112"
  serv["bird4-360"]="124"
  serv["bird4-540"]="268"
  serv["bird4-720"]="228"
  serv["bird4-1080"]="420"
  serv["bird5-360"]="24"
  serv["bird5-540"]="48"
  serv["bird5-720"]="54"
  serv["bird5-1080"]="113"
  serv["bird6-360"]="63"
  serv["bird6-540"]="134"
  serv["bird6-720"]="123"
  serv["bird6-1080"]="254"

  declare -A noserv
  noserv["bird1-360"]="44"
  noserv["bird1-540"]="82"
  noserv["bird1-720"]="74"
  noserv["bird1-1080"]="161"
  noserv["bird2-360"]="55"
  noserv["bird2-540"]="94"
  noserv["bird2-720"]="81"
  noserv["bird2-1080"]="156"
  noserv["bird3-360"]="31"
  noserv["bird3-540"]="60"
  noserv["bird3-720"]="53"
  noserv["bird3-1080"]="107"
  noserv["bird4-360"]="123"
  noserv["bird4-540"]="271"
  noserv["bird4-720"]="214"
  noserv["bird4-1080"]="416"
  noserv["bird5-360"]="24"
  noserv["bird5-540"]="48"
  noserv["bird5-720"]="49"
  noserv["bird5-1080"]="107"
  noserv["bird6-360"]="63"
  noserv["bird6-540"]="133"
  noserv["bird6-720"]="109"
  noserv["bird6-1080"]="252"
  noserv["frog1-360"]="45"
  noserv["frog1-540"]="91"
  noserv["frog1-720"]="69"
  noserv["frog1-1080"]="142"
  noserv["frog2-360"]="34"
  noserv["frog2-540"]="70"
  noserv["frog2-720"]="63"
  noserv["frog2-1080"]="151"
  noserv["frog3-360"]="15"
  noserv["frog3-540"]="28"
  noserv["frog3-720"]="32"
  noserv["frog3-1080"]="73"
  noserv["frog4-360"]="45"
  noserv["frog4-540"]="88"
  noserv["frog4-720"]="135"
  noserv["frog5-360"]="28"
  noserv["frog5-540"]="59"
  noserv["frog5-720"]="92"
  noserv["frog5-1080"]="229"
  noserv["frog6-360"]="24"
  noserv["frog6-540"]="53"
  noserv["frog6-720"]="41"
  noserv["frog6-1080"]="92"
  noserv["seagull1-360"]="36"
  noserv["seagull1-720"]="87"
  noserv["seagull1-1080"]="197"
  noserv["seagull2-360"]="15"
  noserv["seagull2-540"]="28"
  noserv["seagull2-720"]="26"
  noserv["seagull2-1080"]="48"
  noserv["seagull3-360"]="65"
  noserv["seagull3-540"]="135"
  noserv["seagull3-720"]="100"
  noserv["seagull3-1080"]="204"
  noserv["seagull4-360"]="25"
  noserv["seagull4-540"]="45"
  noserv["seagull4-720"]="42"
  noserv["seagull4-1080"]="83"
  noserv["seagull5-360"]="55"
  noserv["seagull5-540"]="106"
  noserv["seagull5-720"]="92"
  noserv["seagull5-1080"]="212"
  noserv["seagull6-360"]="37"
  noserv["seagull6-540"]="77"
  noserv["seagull6-720"]="62"
  noserv["seagull6-1080"]="124"

  if [[ ${test_type} == "serv" ]];
  then
    exptime=$(echo "${exptime} + ${serv["$1"]}" | bc)
  elif [[ ${test_type} == "noserv" ]]; then
    exptime=$(echo "${exptime} + ${noserv["$1"]}" | bc)
  fi
}

function generate_load_animal {
  mycopy animals/$1/$2/$1$2-$3.mp4 "input"
  sumtime "$1$2-$3"
}

function generate_load {
#  for run in {1..6}; do
#    generate_load_animal "frog" "${run}" "360"
#    generate_load_animal "frog" "${run}" "540"
#    generate_load_animal "frog" "${run}" "720"
#    generate_load_animal "frog" "${run}" "1080"
#  done
  generate_load_animal "frog" "1" "1080"
  generate_load_animal "frog" "1" "360"
  generate_load_animal "frog" "2" "360"
  generate_load_animal "frog" "3" "360"
  generate_load_animal "seagull" "1" "1080"
  generate_load_animal "bird" "1" "540"
  generate_load_animal "seagull" "3" "1080"
  generate_load_animal "bird" "5" "540"
  generate_load_animal "bird" "4" "360"
  generate_load_animal "bird" "4" "540"
  generate_load_animal "bird" "6" "720"
  generate_load_animal "bird" "5" "360"
  generate_load_animal "frog" "5" "360"
  generate_load_animal "seagull" "2" "1080"

  echo "Waiting 20 seconds to allow container to start"
  sleep 20
  echo "Experiment estimated time is ${exptime}"
  sleep_time=$(echo "${exptime} * 1.25" | bc )
  echo "Going to wait for ${sleep_time} to leave some margin"
  sleep ${sleep_time}
  exptime=0

  # Frogs take around 2100 seconds in normal and 2180 in serverless
  #sleep 2250
  #sleep 2250

#  for run in {1..6}; do
#    ls animals/seagulls/${run}/seagull${run}-360.mp4
#    mycopy animals/seagulls/${run}/seagull${run}-360.mp4 "input"
#    mycopy animals/seagulls/${run}/seagull${run}-540.mp4 "input"
#    mycopy animals/seagulls/${run}/seagull${run}-720.mp4 "input"
#    mycopy animals/seagulls/${run}/seagull${run}-1080.mp4 "input"
#  done
  # Seagulls take around X seconds in normal and Y in serverless
  #sleep 2250

#  for run in {1..6}; do
#    ls animals/birds/${run}/bird${run}-360.mp4
#    mycopy animals/birds/${run}/bird${run}-360.mp4 "input"
#    mycopy animals/birds/${run}/bird${run}-540.mp4 "input"
#    mycopy animals/birds/${run}/bird${run}-720.mp4 "input"
#    mycopy animals/birds/${run}/bird${run}-1080.mp4 "input"
#  done
  # Birds take around X seconds in normal and Y in serverless
#  myecho "Press any key when tasks are done"
#  read -p "Press enter to continue"
}



function configure_rules {
  echo "Configuring Rules"
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_amount.sh default CpuRescaleUp 150
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Rules/change_events_amount.sh default CpuRescaleDown down 2 # default is 6
  apptainer exec instance://sc bash ServerlessContainers/scripts/orchestrator/Guardian/set_event_timeout.sh 60 # default is 80
}

export -f generate_load
export -f generate_load_animal
export -f load_staging_data
export -f configure_rules
export -f sumtime

export CONT_MAX_CPU=600
export LOAD_NAME="transcode"
export TIMEOUT=25
export MIN_BALANCE=1
export MAX_DEBT="-1"
export START_CREDIT=100

bash ${scriptDir}/common.sh


