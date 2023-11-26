function get_times {
  python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_experiment.py info "${EXP}" --username="root"
  python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_test.py info "${EXP}" "1.serv_acct" --username="root"
}

function get_4fold_times {
  python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_experiment.py info "${EXP}" --username="root"
  python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_test.py info "${EXP}" "1.serv_acct" --username="root"
  python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_test.py info "${EXP}" "2.serv_noacct" --username="root"
  python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_test.py info "${EXP}" "3.noserv_acct" --username="root"
  python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_test.py info "${EXP}" "4.noserv_noacct" --username="root"
}

source /home/jonatan/Desktop/development/BDWatchdog/set_pythonpath.sh
BDW_PATH="/home/jonatan/Desktop/development/BDWatchdog/"

#EXP="transcode_basic_1"
#get_times > transcode/basic/transcode_basic_1.txt
#EXP="transcode_basic_2"
#get_times > transcode/basic/transcode_basic_2.txt
#EXP="transcode_basic_3"
#get_times > transcode/basic/transcode_basic_3.txt
#EXP="transcode_basic_4"
#get_times > transcode/basic/transcode_basic_4.txt
#
#EXP="transcode_greedy_1"
#get_times > transcode/greedy/transcode_greedy_1.txt
#EXP="transcode_greedy_2"
#get_times > transcode/greedy/transcode_greedy_2.txt
#EXP="transcode_greedy_3"
#get_times > transcode/greedy/transcode_greedy_3.txt
#EXP="transcode_greedy_4"
#get_times > transcode/greedy/transcode_greedy_4.txt
#
#EXP="transcode_4fold_1"
#get_4fold_times > transcode/4fold/transcode_4fold_1.txt
#EXP="transcode_4fold_2"
#get_4fold_times > transcode/4fold/transcode_4fold_2.txt
#EXP="transcode_4fold_3"
#get_4fold_times > transcode/4fold/transcode_4fold_3.txt
#EXP="transcode_4fold_4"
#get_4fold_times > transcode/4fold/transcode_4fold_4.txt
#
#EXP="genomics_greedy_1"
#get_times > genomics/greedy/genomics_greedy_1.txt
#EXP="genomics_greedy_2"
#get_times > genomics/greedy/genomics_greedy_2.txt
#EXP="genomics_greedy_3"
#get_times > genomics/greedy/genomics_greedy_3.txt
#EXP="genomics_greedy_4"
#get_times > genomics/greedy/genomics_greedy_4.txt
#
#EXP="genomics_conservative_1"
#get_times > genomics/conservative/genomics_conservative_1.txt
#EXP="genomics_conservative_2"
#get_times > genomics/conservative/genomics_conservative_2.txt
#EXP="genomics_conservative_3"
#get_times > genomics/conservative/genomics_conservative_3.txt
#EXP="genomics_conservative_4"
#get_times > genomics/conservative/genomics_conservative_4.txt
#
#EXP="genomics_4fold_1"
#get_4fold_times > genomics/4fold/genomics_4fold_1.txt
#EXP="genomics_4fold_2"
#get_4fold_times > genomics/4fold/genomics_4fold_2.txt
#EXP="genomics_4fold_3"
#get_4fold_times > genomics/4fold/genomics_4fold_3.txt
#EXP="genomics_4fold_4"
#get_4fold_times > genomics/4fold/genomics_4fold_4.txt

EXP="GRC_EXP"
python3 ${BDW_PATH}/TimestampsSnitch/src/timestamping/signal_experiment.py info "${EXP}" --username="root" > grc_exp.txt