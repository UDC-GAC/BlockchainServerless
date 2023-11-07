scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function generate_load {
  count=10
  for i in $(seq $count); do
      mc cp video0.mp4 myminio/gif/input/video${i}.mp4
  done
  myecho "Waiting"
  sleep 110
}

export -f generate_load

export LOAD_NAME="gif"
export TIMEOUT=45
export MIN_BALANCE=1
export MAX_DEBT="-1"
export START_CREDIT=2

bash ${scriptDir}/common.sh