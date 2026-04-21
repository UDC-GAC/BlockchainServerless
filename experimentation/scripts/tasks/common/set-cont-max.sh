scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
if [ "$#" -lt 1 ]
then
  echo "1 argument is expected"
  echo "+ the max amount to set in the container base template"
  exit 1
fi
cat ${scriptDir}/cont-layout.json | jq '.resources.cpu.max = $v' --arg v ${1} | sponge ${scriptDir}/cont-layout.json
jq  -c '.resources.cpu.max |= tonumber ' ${scriptDir}/cont-layout.json  | sponge ${scriptDir}/cont-layout.json
cat ${scriptDir}/cont-layout.json | python -m json.tool | sponge ${scriptDir}/cont-layout.json
