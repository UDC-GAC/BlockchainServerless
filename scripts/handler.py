import time

import requests
import subprocess
from minio import Minio
from minio.error import S3Error

# MinIO configuration
minio_endpoint = "10.10.255.231:9000"
minio_access_key = "minioadmin"
minio_secret_key = "minioadmin"

# Initialize MinIO client
minio_client = Minio(
    minio_endpoint,
    access_key=minio_access_key,
    secret_key=minio_secret_key,
    secure=False  # Change to True for secure connection (HTTPS)
)


def container_is_running(cont_name):
    p1 = subprocess.Popen(["sudo", "apptainer", "instance", "list", cont_name], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(["grep", cont_name], stdin=p1.stdout, stdout=subprocess.PIPE)
    out1, out2 = p2.communicate()
    return out1 != b''


def get_user_info(user_name):
    return requests.get(url="http://10.10.255.231:5000/user/{0}".format(user_name)).json()


def data_in_bucket_path(bucket, path):
    try:
        return minio_client.list_objects(bucket, start_after=path)
    except S3Error as e:
        print(f"Error listing files for path {0} in bucket {1}".format(path, bucket))
        raise e


def data_present_in_input(bucket, path):
    objects = data_in_bucket_path(bucket, path)
    if objects:
        return True
    else:
        return False

def start_container():
    print("Starting container")
    subprocess.run(["bash", "/home/jonatan.enes/start_container.sh"])

def stop_container():
    print("Stopping container")
    subprocess.run(["bash", "/home/jonatan.enes/stop_container.sh"])


def get_user_status(user_name):
    user_info = get_user_info(user_name)
    print(user_info)
    user_balance = user_info["accounting"]["coins"]
    user_max_debt = user_info["accounting"]["max_debt"]
    user_min_balance = user_info["accounting"]["min_balance"]
    if user_balance > user_min_balance and user_balance > 0:
        return "normal"
    elif user_balance < user_min_balance and user_balance >= 0:
        return "broke"
    elif user_balance < 0 and user_balance > user_max_debt:
        return "indebt"
    elif user_balance < 0 and user_balance < user_max_debt:
        return "scammer"
    else:
        return "unknown"


if __name__ == '__main__':
    user = "user0"
    cont = "cont0"
    bucket = "gatk"
    path = "/sample/input"

    print("User status is {0}".format(get_user_status(user)))

    container_running = container_is_running(cont)
    if container_running:
        print("User has a container already running")
    else:
        print("User does not have a container running")

    data_in_input = data_present_in_input(bucket, path)
    if data_in_input:
        print("There is data to be processed in the input {0}/{1}".format(bucket, path))
    else:
        print("There is no data to be processed in the input {0}/{1}".format(bucket, path))


    start_container()
    time.sleep(10)
    stop_container()
