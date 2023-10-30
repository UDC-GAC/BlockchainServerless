import time

import requests
import subprocess
from minio import Minio
from minio.error import S3Error
from multiprocessing import Process

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

worker_process = None

def container_is_running(cont_name):
    p1 = subprocess.Popen(["sudo", "apptainer", "instance", "list", cont_name], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(["grep", cont_name], stdin=p1.stdout, stdout=subprocess.PIPE)
    out1, out2 = p2.communicate()
    return out1 != b''


def get_user_info(user_name):
    return requests.get(url="http://10.10.255.231:5000/user/{0}".format(user_name)).json()


def data_in_bucket_path(bucket, path):
    try:
        return minio_client.list_objects(bucket, prefix=path)
    except S3Error as e:
        print(f"Error listing files for path {0} in bucket {1}".format(path, bucket))
        raise e


def data_present_in_input(bucket, path):
    objects = data_in_bucket_path(bucket, path)
    #print("-------------")
    #print("{0}/{1}".format(bucket, path))
    i = 0
    for obj in objects:
        #print(obj.object_name)
        i +=1
    #print("-------------")
    if i > 1:
        return True
    else:
        return False


def start_container():
    subprocess.run(["bash", "/home/jonatan.enes/start_container.sh"])


def stop_container():
    subprocess.run(["bash", "/home/jonatan.enes/stop_container.sh"])


def get_user_status(user_name):
    user_info = get_user_info(user_name)
    user_balance = user_info["accounting"]["coins"]
    user_max_debt = user_info["accounting"]["max_debt"]
    user_min_balance = user_info["accounting"]["min_balance"]
    if user_balance > user_min_balance and user_balance > 0:
        status = "normal"
    elif user_balance < user_min_balance and user_balance >= 0:
        status = "broke"
    elif user_balance < 0 and user_balance > user_max_debt:
        status = "indebt"
    elif user_balance < 0 and user_balance < user_max_debt:
        status = "scammer"
    else:
        status = "unknown"
    print("User status is current: {0}, min_balance: {1}, max_debt: {2}, --> {3}".format(user_balance, user_min_balance,
                                                                                user_max_debt, status))
    return status

def run_in_worker_process(command):
    subprocess.run(command)

def run_new_task(bucket, path):
    objects = data_in_bucket_path(bucket, path)
    next(objects) # First one is the directory
    new_task = next(objects).object_name
    new_task = new_task.replace(path, "")
    print("Will run new task of type {0} with file '{1}'".format(bucket, new_task))
    command = ["bash", "/home/jonatan.enes/tasks/{0}/run-load.sh".format(bucket), new_task]
    worker_process = Process(target=run_in_worker_process, args=(command,))
    worker_process.start()



if __name__ == '__main__':
    user = "user0"
    cont = "cont0"
    bucket = "stress"

    while True:
        user_status = get_user_status(user)
        container_running = container_is_running(cont)
        data_in_input = data_present_in_input(bucket, "input/")
        data_in_processing = data_present_in_input(bucket, "processing/")


        if container_running:
            print("Container already running")
            if user_status in ["normal", "broke"]:
                print("User has enough credit")
                if data_in_processing:
                    print("There is data being processed")
                elif data_in_input:
                    print("There is data waiting to be processed")
                    print("Running new task")
                    run_new_task(bucket, "input/")
                else:
                    print("No data waiting to be processed")
            elif user_status in ["indebt"]:
                print("User is in debt")
                if data_in_processing:
                    print("There is data being processed")
                elif data_in_input:
                    print("There is data waiting to be processed")
                    print("Because user is in debt, no new job is submitted")
                else:
                    print("No data waiting to be processed")
            elif user_status in ["scammer"]:
                print("User is in HEAVY debt, stopping the running container")
                stop_container()
        else:
            print("There is no container running")
            if user_status in ["normal", "broke"]:
                print("User has enough credit")
                if data_in_input:
                    print("There is data waiting to be processed")
                    print("Starting container")
                    start_container()
                    print("Running new task")
                    run_new_task(bucket, "input/")
                else:
                    print("There is NO data waiting to be processed")
            elif user_status in ["indebt", "scammer"]:
                print("User is in debt")
                if data_in_input:
                    print("There is data waiting to be processed")
                    print("Because user is in debt, no container will be started")
                else:
                    print("There is NO data waiting to be processed")

        time.sleep(5)

