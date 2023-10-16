
SampleID=$1
MicrobeID=$2
if test -z "$SampleID"
then
     echo "No sample ID was specified"
     exit 1
fi

if test -z "$MicrobeID"
then
     echo "No microbe id was specified"
     exit 1
fi

OutFile="${OutputDir}/stage2-sample.${SampleID}-microbe.${MicrobeID}.out"

echo "Pairing with Microbe references" &> ${OutFile}
${GatkBin} PathSeqBwaSpark  \
   --paired-input ${OutputDir}/${SampleID}_paired.bam \
   --unpaired-input ${OutputDir}/${SampleID}_unpaired.bam \
   --paired-output ${OutputDir}/${SampleID}_pairedV2.bam \
   --unpaired-output ${OutputDir}/${SampleID}_unpairedV2.bam \
   --microbe-bwa-image ${OutputDir}/bacteria.${MicrobeID}.1.genomic.fasta.img \
   --microbe-dict ${OutputDir}/bacteria.${MicrobeID}.1.genomic.dict \
   -- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 45G \
   &>> ${OutFile}
   

echo "Identification of paired sequences with reference taxonomy" &>> ${OutFile}
${GatkBin} PathSeqScoreSpark \
	--paired-input ${OutputDir}/${SampleID}_pairedV2.bam \
	--unpaired-input ${OutputDir}/${SampleID}_unpairedV2.bam \
	--taxonomy-file ${OutputDir}/taxonomy${MicrobeID}.db \
	--scores-output ${OutputDir}/${SampleID}_scores.${MicrobeID}.txt \
	--output ${OutputDir}/${SampleID}_output.${MicrobeID}.bam \
	--min-score-identity 0.90 \
	--identity-margin 0.02 \
	-- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 45G \
	&>> ${OutFile}



