scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
max=$(cat ${scriptDir}/stress/cont-layout.json | jq '.resources.cpu.max | tonumber')
value=$(echo "${max} / 2" | bc)
echo $value

cat ${scriptDir}/stress/cont-layout.json | jq '.resources.cpu.current = $v' --arg v ${value} | sponge ${scriptDir}/stress/cont-layout.json
jq  -c '.resources.cpu.current |= tonumber ' ${scriptDir}/stress/cont-layout.json  | sponge ${scriptDir}/stress/cont-layout.json
cat ${scriptDir}/stress/cont-layout.json | python -m json.tool | sponge ${scriptDir}/stress/cont-layout.json
