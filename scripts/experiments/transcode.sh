scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

function generate_load {
#  count=1
#  for i in $(seq $count); do
#      mc cp video0.mp4 myminio/transcode/input/video${i}.mp4
#  done
  mc cp video1.mp4 myminio/transcode/input/
  mc cp video2.mp4 myminio/transcode/input/
  mc cp video3.mp4 myminio/transcode/input/
  myecho "Waiting"
  sleep 110
}

export -f generate_load

export LOAD_NAME="transcode"
export TIMEOUT=45
export MIN_BALANCE=1
export MAX_DEBT="-1"
export START_CREDIT=40

bash ${scriptDir}/common.sh