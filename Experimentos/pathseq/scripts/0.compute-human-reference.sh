## Human reference pipeline ##

## Dictionary
${GatkBin} CreateSequenceDictionary \
	--REFERENCE ${InputDir}/Homo_sapiens_assembly38.fasta \
	--OUTPUT ${InputDir}/Homo_sapiens_assembly38.dict

## Index
samtools faidx /root/experiments/Homo_sapiens_assembly38.fasta

## Create Human references (k-mer files and BWA image files)
${GatkBin} BwaMemIndexImageCreator \
     -I ${InputDir}/Homo_sapiens_assembly38.fasta \
     -O ${InputDir}/Homo_sapiens_assembly38.fasta.img

${GatkBin} PathSeqBuildKmers \
   --reference ${InputDir}/Homo_sapiens_assembly38.fasta \
   --output ${InputDir}/Homo_sapiens_assembly38.hss \
   --kmer-mask 16 \
   --kmer-size 31 \
   --java-options "-Xmx45g"
