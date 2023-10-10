exit 0

git clone https://github.com/spcl/serverless-benchmarks.git

### MINIO
./sebs.py storage start minio --port 9011 --output-json out_storage.json
set ADDRESS $(jq -r '.address' out_storage.json)
set ACCESS_KEY $(jq -r '.access_key' out_storage.json)
set SECRET_KEY $(jq -r '.secret_key' out_storage.json)
mc config host add minio http://{$ADDRESS} {$ACCESS_KEY} {$SECRET_KEY}
mc ls minio/
mc mb minio/input-bkt
mc mb minio/output-bkt

### Prepare
# Config
jq --argfile file1 out_storage.json '.deployment.local.storage = $file1 ' config/example.json > local_deployment.json
# Sample data
mkdir /root/serverless-benchmarks-data
git clone https://github.com/spcl/serverless-benchmarks-data.git /root/serverless-benchmarks-data


# ~~~~~~~~~~ Thumbnailer ~~~~~~~~~~~~~~~~~~

# This is needed just so that the docker start does not fail
mkdir benchmarks-data/210.thumbnailer
cp /root/serverless-benchmarks-data/200.multimedia/210.thumbnailer/* benchmarks-data/210.thumbnailer/

# Start the function in a docker container
./sebs.py local start 210.thumbnailer test out_benchmark.json --config local_deployment.json --deployments 1

# Copy the actual data to process
mc cp benchmarks-data/210.thumbnailer/* minio/input-bkt

# Run something and check that it works
set FUNC_ADDRESS $(jq -r '.functions[0].url' out_benchmark.json)
curl {$FUNC_ADDRESS} --request POST --data '{"bucket": {"input": "input-bkt","output": "output-bkt"}, "object": {"key": "0_action-adrenaline-adventure-1047051.jpg","height":200,"width": 200}}' --header 'Content-Type: application/json'
mc cp minio/output-bkt/0_action-adrenaline-adventure-1047051.e3d4db71.jpg /opt/plane

# ~~~~~~~~~~ Video processing ~~~~~~~~~~~~~~~~~~

# This is needed just so that the docker start does not fail
mkdir benchmarks-data/220.video-processing
cp /root/serverless-benchmarks-data/200.multimedia/220.video-processing/city.mp4 benchmarks-data/220.video-processing/

# Start the function in a docker container
./sebs.py local start 220.video-processing test out_benchmark.json --config local_deployment.json --deployments 1

# Copy the actual data to process
mc cp benchmarks-data/220.video-processing/* minio/input-bkt

# Run something and check that it works
set FUNC_ADDRESS $(jq -r '.functions[0].url' out_benchmark.json)

# This is for watermark
curl {$FUNC_ADDRESS} --request POST --data '{"bucket": {"input": "input-bkt","output": "output-bkt"}, "object": {"key": "city.mp4", "duration": 10, "op":"watermark"}}' --header 'Content-Type: application/json'
mc cp minio/output-bkt/processed-city.f6819519.mp4 /opt/plane

# This is for GIF
# Para las operaciones de extracción de GIF, hay un bug, hay que quitarles la extensión MP4 a los ficheros
mc mv minio/input-bkt/city.mp4  minio/input-bkt/city
curl {$FUNC_ADDRESS} --request POST --data '{"bucket": {"input": "input-bkt","output": "output-bkt"}, "object": {"key": "city", "duration": 5, "op":"extract-gif"}}' --header 'Content-Type: application/json'
mc cp minio/output-bkt/processed-city.29b2e3ad.gif /opt/plane

# ~~~~~~~~~~ Compression ~~~~~~~~~~~~~~~~~~

# This is needed just so that the docker start does not fail
mkdir benchmarks-data/311.compression/
cp -r /root/serverless-benchmarks-data/300.utilities/311.compression/* benchmarks-data/311.compression/

# Start the function in a docker container
./sebs.py local start 311.compression small out_benchmark.json --config local_deployment.json --deployments 1

# Copy the actual data to process
mc cp -r benchmarks-data/311.compression/* minio/input-bkt

# Run something and check that it works
set FUNC_ADDRESS $(jq -r '.functions[0].url' out_benchmark.json)
curl {$FUNC_ADDRESS} --request POST --data '{"bucket": {"input": "input-bkt", "output": "output-bkt"}, "object":{"key":"acmart"}}' --header 'Content-Type: application/json'
mc cp minio/output-bkt/acmart.8efd1095.zip /opt/plane/

# ~~~~~~~~~~ Image recognition ~~~~~~~~~~~~~~~~~~

# This is needed just so that the docker start does not fail
mkdir benchmarks-data/411.image-recognition/
cp -r /root/serverless-benchmarks-data/400.inference/411.image-recognition/fake-resnet/ benchmarks-data/411.image-recognition/
cp -r /root/serverless-benchmarks-data/400.inference/411.image-recognition/model/ benchmarks-data/411.image-recognition/

# Start the function in a docker container
./sebs.py local start 411.image-recognition small out_benchmark.json --config local_deployment.json --deployments 1

# Copy the actual data to process
mc cp benchmarks-data/411.image-recognition/fake-resnet/* minio/input-bkt
mc cp benchmarks-data/411.image-recognition/model/resnet50-19c8e357.pth minio/input-bkt

# Run something and check that it works
set FUNC_ADDRESS $(jq -r '.functions[0].url' out_benchmark.json)
curl {$FUNC_ADDRESS} -s --request POST --data '{"bucket": {"input": "input-bkt", "model":"input-bkt"}, "object":{"input":"800px-Sardinian_Warbler.jpg", "model":"resnet50-19c8e357.pth"}}' --header 'Content-Type: application/json' | jq '.result.output.result.class'

