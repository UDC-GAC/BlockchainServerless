scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

REPORTS_PATH="/home/jonatan/Desktop/development/ServerlessContainersReportGenerator/REPORTS"
TRANSCODE_PATH="${scriptDir}/transcode"
GENOMICS_PATH="${scriptDir}/genomics"

echo "Removing old plots"
rm -Rf ${TRANSCODE_PATH}
mkdir -p ${TRANSCODE_PATH}/basic
mkdir -p ${TRANSCODE_PATH}/greedy
mkdir -p ${TRANSCODE_PATH}/4fold/serv_acct
mkdir -p ${TRANSCODE_PATH}/4fold/serv_noacct
mkdir -p ${TRANSCODE_PATH}/4fold/noserv_acct
mkdir -p ${TRANSCODE_PATH}/4fold/noserv_noacct
rm -Rf ${GENOMICS_PATH}
mkdir -p ${GENOMICS_PATH}/conservative
mkdir -p ${GENOMICS_PATH}/greedy
mkdir -p ${GENOMICS_PATH}/4fold/serv_acct
mkdir -p ${GENOMICS_PATH}/4fold/serv_noacct
mkdir -p ${GENOMICS_PATH}/4fold/noserv_acct
mkdir -p ${GENOMICS_PATH}/4fold/noserv_noacct

echo "Bringing back Transcode plots"

echo "Greedy"
PLOTS_PATH="${REPORTS_PATH}/transcode_greedy_1/timeseries_plots/1.serv_acct"
EXP="greedy"
cp "${PLOTS_PATH}/transcode-cont_cpu.png" ${TRANSCODE_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${TRANSCODE_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${TRANSCODE_PATH}/${EXP}/tasks.png

echo "Basic"
PLOTS_PATH="${REPORTS_PATH}/transcode_basic_1/timeseries_plots/1.serv_acct"
EXP="basic"
cp "${PLOTS_PATH}/transcode-cont_cpu.png" ${TRANSCODE_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${TRANSCODE_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${TRANSCODE_PATH}/${EXP}/tasks.png

echo "4fold"
PLOTS_PATH="${REPORTS_PATH}/transcode_4fold_1/timeseries_plots/1.serv_acct"
EXP="4fold/serv_acct"
cp "${PLOTS_PATH}/transcode-cont_cpu.png" ${TRANSCODE_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${TRANSCODE_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${TRANSCODE_PATH}/${EXP}/tasks.png
PLOTS_PATH="${REPORTS_PATH}/transcode_4fold_1/timeseries_plots/2.serv_noacct"
EXP="4fold/serv_noacct"
cp "${PLOTS_PATH}/transcode-cont_cpu.png" ${TRANSCODE_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${TRANSCODE_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${TRANSCODE_PATH}/${EXP}/tasks.png
PLOTS_PATH="${REPORTS_PATH}/transcode_4fold_1/timeseries_plots/3.noserv_acct"
EXP="4fold/noserv_acct"
cp "${PLOTS_PATH}/transcode-cont_cpu.png" ${TRANSCODE_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${TRANSCODE_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${TRANSCODE_PATH}/${EXP}/tasks.png
PLOTS_PATH="${REPORTS_PATH}/transcode_4fold_1/timeseries_plots/4.noserv_noacct"
EXP="4fold/noserv_noacct"
cp "${PLOTS_PATH}/transcode-cont_cpu.png" ${TRANSCODE_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${TRANSCODE_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${TRANSCODE_PATH}/${EXP}/tasks.png



echo "Bringing back Genomics plots"

echo "Greedy"
PLOTS_PATH="${REPORTS_PATH}/genomics_greedy_1/timeseries_plots/1.serv_acct"
EXP="greedy"
cp "${PLOTS_PATH}/genomics-cont_cpu.png" ${GENOMICS_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${GENOMICS_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${GENOMICS_PATH}/${EXP}/tasks.png

echo "Conservative"
PLOTS_PATH="${REPORTS_PATH}/genomics_conservative_1/timeseries_plots/1.serv_acct"
EXP="conservative"
cp "${PLOTS_PATH}/genomics-cont_cpu.png" ${GENOMICS_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${GENOMICS_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${GENOMICS_PATH}/${EXP}/tasks.png

echo "4fold"
PLOTS_PATH="${REPORTS_PATH}/genomics_4fold_1/timeseries_plots/1.serv_acct"
EXP="4fold/serv_acct"
cp "${PLOTS_PATH}/genomics-cont_cpu.png" ${GENOMICS_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${GENOMICS_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${GENOMICS_PATH}/${EXP}/tasks.png
PLOTS_PATH="${REPORTS_PATH}/genomics_4fold_1/timeseries_plots/2.serv_noacct"
EXP="4fold/serv_noacct"
cp "${PLOTS_PATH}/genomics-cont_cpu.png" ${GENOMICS_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${GENOMICS_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${GENOMICS_PATH}/${EXP}/tasks.png
PLOTS_PATH="${REPORTS_PATH}/genomics_4fold_1/timeseries_plots/3.noserv_acct"
EXP="4fold/noserv_acct"
cp "${PLOTS_PATH}/genomics-cont_cpu.png" ${GENOMICS_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${GENOMICS_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${GENOMICS_PATH}/${EXP}/tasks.png
PLOTS_PATH="${REPORTS_PATH}/genomics_4fold_1/timeseries_plots/4.noserv_noacct"
EXP="4fold/noserv_noacct"
cp "${PLOTS_PATH}/genomics-cont_cpu.png" ${GENOMICS_PATH}/${EXP}/cpu.png
cp "${PLOTS_PATH}/user0_accounting.png" ${GENOMICS_PATH}/${EXP}/accounting.png
cp "${PLOTS_PATH}/user0_tasks.png" ${GENOMICS_PATH}/${EXP}/tasks.png