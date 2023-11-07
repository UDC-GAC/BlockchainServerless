scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

cat ${scriptDir}/cont-layout.json | jq '.name = $name' --arg name $1 | sponge ${scriptDir}/cont-layout.json
cat ${scriptDir}/cont-layout.json | python -m json.tool | sponge ${scriptDir}/cont-layout.json