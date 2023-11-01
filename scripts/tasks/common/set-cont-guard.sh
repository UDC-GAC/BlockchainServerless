scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

cat ${scriptDir}/cont-layout.json | jq '.guard = $v' --arg v $1 | sponge ${scriptDir}/cont-layout.json
jq  -c '.guard |= (. == "true") ' ${scriptDir}/cont-layout.json  | sponge ${scriptDir}/cont-layout.json
cat ${scriptDir}/cont-layout.json | python -m json.tool | sponge ${scriptDir}/cont-layout.json