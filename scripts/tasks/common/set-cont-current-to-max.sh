scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
value=$(cat ${scriptDir}/cont-layout.json | jq '.resources.cpu.max | tonumber')
cat ${scriptDir}/cont-layout.json | jq '.resources.cpu.current = $v' --arg v ${value} | sponge ${scriptDir}/cont-layout.json
jq  -c '.resources.cpu.current |= tonumber ' ${scriptDir}/cont-layout.json  | sponge ${scriptDir}/cont-layout.json
cat ${scriptDir}/cont-layout.json | python -m json.tool | sponge ${scriptDir}/cont-layout.json
