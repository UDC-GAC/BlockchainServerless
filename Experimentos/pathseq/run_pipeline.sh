SampleID="13566_5_231"
MicrobeIDs="1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020"
MicrobesPerBatch=4

function launch_auxiliar {
    bash 1.process-microbes.sh "${MicrobeIDs}" ${MicrobesPerBatch}
}

function launch_preprocessing {
    bash 2.process-sample.sh ${SampleID}
}

function launch_processing {
    for i in 
    do
        bash 3.map-sample-microbe.sh ${SampleID} ${i} &
        pids[${i}]=$!
    done
    for pid in ${pids[*]}; do
        wait $pid
    done
}
