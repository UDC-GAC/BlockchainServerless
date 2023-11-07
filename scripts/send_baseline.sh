source BDWatchdog/set_pythonpath.sh
sample="{\"metric\": \"proc.cpu.user\", \"timestamp\": TIME, \"value\": \"0.10\", \"tags\": {\"host\": \"CONT\", \"pid\": \"-1\", \"command\": \"bogus\"}}"
curtime=$(date +%s)
timed_sample=$(echo ${sample} | sed -e "s/TIME/${curtime}/")
echo ${timed_sample} | sed 's/CONT/stress-cont/g' | python3 BDWatchdog/MetricsFeeder/src/pipelines/send_to_OpenTSDB.py
echo ${timed_sample} | sed 's/CONT/transcode-cont/g' | python3 BDWatchdog/MetricsFeeder/src/pipelines/send_to_OpenTSDB.py
echo ${timed_sample} | sed 's/CONT/gif-cont/g' | python3 BDWatchdog/MetricsFeeder/src/pipelines/send_to_OpenTSDB.py

