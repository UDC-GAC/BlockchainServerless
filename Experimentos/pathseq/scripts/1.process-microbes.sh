function process-microbe (){

	# Copy from input to output and decompress
	cp ${InputDir}/bacteria.${MicrobeID}.1.genomic.fna.gz ${OutputDir}/
	gzip -k -d ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fna.gz
	mv ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fna ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fasta

	## Create dictionary
	rm -f bacteria.${MicrobeID}.1.genomic.dict
	${GatkBin} CreateSequenceDictionary \
	  --REFERENCE ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fasta \
	  --OUTPUT ${OutputDir}/bacteria.${MicrobeID}.1.genomic.dict

	## Create index
	samtools faidx ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fasta

	## Taxonomy Database creation
	${GatkBin} PathSeqBuildReferenceTaxonomy \
	   --reference ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fasta \
	   --output ${OutputDir}/taxonomy${MicrobeID}.db \
	   --refseq-catalog ${InputDir}/RefSeq-release93.catalog.gz \
	   --tax-dump ${InputDir}/taxdump.tar.gz
	${GatkBin} BwaMemIndexImageCreator \
		 -I  ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fasta \
		 -O  ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fasta.img	
	
}
	
	
ids=$1
MicrobesPerBatch=$2

if test -z "$ids"
then
    echo "No bacteria ids have been specified"
    exit 1
else
	echo "Going to process '${ids}'"
fi

if test -z "$MicrobesPerBatch"
then
    echo "No number of microbes per batch has been specified"
    exit 1
fi

# Conert to array
ids=($ids)

# get length of an array
arraylength=${#ids[@]}
for (( i=0; i<${arraylength}; i++ ));
do

    n=$(($i%$MicrobesPerBatch))
    if [[ "${n}" -eq 0 ]]
    then
		for pid in ${pids[*]}; do
			echo "Now waiting for pid=${pid}"
			wait $pid
		done
		unset pids
    fi

	MicrobeID=${ids[$i]}
	echo "Processing ${id}"
	process-microbe &> ${OutputDir}/stage0-microbe.${MicrobeID}.out &
    #bash ${ScriptsDir}/process-single-microbe.sh ${id} &> ${OutputDir}/stage0-microbe.${id}.out &
    pids[${MicrobeID}]=$!
done

# Wait for the remaining
for pid in ${pids[*]}; do
	echo "Now waiting for pid=${pid}"
	wait $pid
done


#for i in "${ids[@]}"
#do
    #bash ${ScriptsDir}/1.process-microbe.sh ${i} &> ${OutputDir}/stage0-microbe.${i}.out &
    #pids[${i}]=$!
#done
#for pid in ${pids[*]}; do
    #wait $pid
#done
