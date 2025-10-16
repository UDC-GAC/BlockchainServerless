export MONGODB_IP=192.168.51.242
source /home/jonatan/Desktop/BAY/investigacion/BDWatchdog/set_pythonpath.sh
BDW_PATH="/home/jonatan/Desktop/BAY/investigacion/BDWatchdog"

cat $1 | python3 ${BDW_PATH}/TimestampsSnitch/src/mongodb/mongodb_agent.py
