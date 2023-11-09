LOAD_FUNC="Genomics"

echo "----------------------"
echo "Processing task of type ${LOAD_FUNC}"
if [ "$#" -lt 2 ]
then
  echo "2 arguments are expected"
  echo "+ the path of the file (task)"
  echo "+ the path for the output files"
  exit 1
fi

TASK_NAME=$1
OUT_DIR=$2

echo "Running the ${LOAD_FUNC} function now"
echo "Time is $(date "+%H:%M")"
start_time=$(date "+%s")
echo "Taskfile is ${TASK_NAME}"
echo "Results dir are ${OUT_DIR}"
IN_FILE=$(basename ${TASK_NAME})
echo "Input file is ${IN_FILE}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


GatkBin="/opt/gatk/gatk"
EnvDir="/staging"
SampleID="13566_5_232"
PAR_DEGREE=10
StagingDir="/staging/results"

rm -Rf ${StagingDir}
mkdir -p ${StagingDir}


echo "Decompress"
cp ${TASK_NAME} ${StagingDir}/
gzip -k -d ${StagingDir}/${IN_FILE}
BASE_FILE=$(echo "${StagingDir}/${IN_FILE}" | sed 's/.fna.gz//g')
FASTA_FILE="${BASE_FILE}.fasta"
mv "${BASE_FILE}.fna" ${FASTA_FILE}

echo "Creating dictionary"
#rm -f bacteria.${MicrobeID}.1.genomic.dict
DICT_FILE="${BASE_FILE}.dict"
${GatkBin} CreateSequenceDictionary --REFERENCE ${FASTA_FILE} --OUTPUT ${DICT_FILE}

echo "Creating index"
samtools faidx ${FASTA_FILE}

echo "Taxonomy Database creation"
TAX_FILE="${BASE_FILE}.taxonomy.db"
${GatkBin} PathSeqBuildReferenceTaxonomy \
   --reference ${FASTA_FILE} \
   --output ${TAX_FILE} \
   --refseq-catalog ${EnvDir}/RefSeq-release93.catalog.gz \
   --tax-dump ${EnvDir}/taxdump.tar.gz
${GatkBin} BwaMemIndexImageCreator \
         -I  ${FASTA_FILE} \
         -O  ${FASTA_FILE}.img

#echo "Running BwaSpark (alignment)"
#${GatkBin} BwaSpark  \
#   -se true  \
#   --input ${EnvDir}/${SampleID}.bam \
#   --output ${StagingDir}/${SampleID}_aligned.bam \
#   --reference ${EnvDir}/Homo_sapiens_assembly38.fasta \
#   -- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 80G
#
#echo "Running PathSeqFilterSpark (filtering)"
#${GatkBin} PathSeqFilterSpark  \
#   --input ${StagingDir}/${SampleID}_aligned.bam \
#   --paired-output ${StagingDir}/${SampleID}_paired.bam \
#   --unpaired-output ${StagingDir}/${SampleID}_unpaired.bam \
#   --min-clipped-read-length 60 \
#   --kmer-file ${EnvDir}/Homo_sapiens_assembly38.hss \
#   --filter-bwa-image ${EnvDir}/Homo_sapiens_assembly38.fasta.img \
#   -- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 80G


echo "Pairing with Microbe references from ${IN_FILE}"
${GatkBin} PathSeqBwaSpark  \
   --paired-input ${EnvDir}/${SampleID}_paired.bam \
   --unpaired-input ${EnvDir}/${SampleID}_unpaired.bam \
   --paired-output ${EnvDir}/${SampleID}_pairedV2.bam \
   --unpaired-output ${EnvDir}/${SampleID}_unpairedV2.bam \
   --microbe-bwa-image ${FASTA_FILE}.img \
   --microbe-dict ${DICT_FILE} \
   -- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 80G


echo "Identification of paired sequences with reference taxonomy"
${GatkBin} PathSeqScoreSpark \
        --paired-input ${EnvDir}/${SampleID}_pairedV2.bam \
        --unpaired-input ${EnvDir}/${SampleID}_unpairedV2.bam \
        --taxonomy-file ${TAX_FILE} \
        --scores-output ${StagingDir}/scores.txt \
        --output ${StagingDir}/output.bam \
        --min-score-identity 0.90 \
        --identity-margin 0.02 \
        -- --spark-runner SPARK --spark-master local[${PAR_DEGREE}] --driver-memory 80G

cp ${StagingDir}/scores.txt ${OUT_DIR}

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

echo "Finished running the load"
end_time=$(date "+%s")
time_diff=$(echo "${end_time} - ${start_time}" | bc)
echo "Time is $(date "+%H:%M"), it took ${time_diff} seconds"
exit $exit_code