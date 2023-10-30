export CONT_NAME="cont0"
sudo apptainer instance stop ${CONT_NAME}

curl -X DELETE -H "Content-Type: application/json" http://10.10.255.231:5000/structure/container/${CONT_NAME}
