source BDWatchdog/set_pythonpath.sh
sample="{\"metric\": \"proc.cpu.user\", \"timestamp\": TIME, \"value\": \"0.10\", \"tags\": {\"host\": \"cont0\", \"pid\": \"-1\", \"command\": \"bogus\"}}"
curtime=$(date +%s)
echo ${sample} | sed -e "s/TIME/${curtime}/" | python3 BDWatchdog/MetricsFeeder/src/pipelines/send_to_OpenTSDB.py
