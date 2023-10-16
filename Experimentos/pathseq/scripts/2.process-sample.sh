SampleID=$1

if test -z "$SampleID"
then
     echo "No sample ID was specified"
     exit 1
fi

OutFile="${OutputDir}/stage1-sample.${SampleID}.out"

## Align with Human references
echo "Running BwaSpark (alignment)" &> ${OutFile}
${GatkBin} BwaSpark  \
	-se true  \
   --input ${InputDir}/${SampleID}.bam \
   --output ${OutputDir}/${SampleID}_aligned.bam \
   --reference ${InputDir}/Homo_sapiens_assembly38.fasta \
   -- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 45G --executor-memory 5G \
   &>> ${OutFile}
   
echo "Running PathSeqFilterSpark (filtering)" &>> ${OutFile}
${GatkBin} PathSeqFilterSpark  \
   --input ${OutputDir}/${SampleID}_aligned.bam \
   --paired-output ${OutputDir}/${SampleID}_paired.bam \
   --unpaired-output ${OutputDir}/${SampleID}_unpaired.bam \
   --min-clipped-read-length 60 \
   --kmer-file ${InputDir}/Homo_sapiens_assembly38.hss \
   --filter-bwa-image ${InputDir}/Homo_sapiens_assembly38.fasta.img \
   -- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 45G --executor-memory 5G \
   &>> ${OutFile}
