source /home/jonatan/Desktop/development/BDWatchdog/set_pythonpath.sh
BDW_PATH="/home/jonatan/Desktop/development/BDWatchdog"
cat $1 | python3 ${BDW_PATH}/TimestampsSnitch/src/mongodb/mongodb_agent.py