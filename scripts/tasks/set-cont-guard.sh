scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

cat ${scriptDir}/stress/cont-layout.json | jq '.guard = $v' --arg v $1 | sponge ${scriptDir}/stress/cont-layout.json