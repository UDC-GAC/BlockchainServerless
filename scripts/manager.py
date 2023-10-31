import time

import requests
import subprocess
from minio import Minio
from minio.error import S3Error
from multiprocessing import Process


worker_process = None
SCRIPTS_BASE_PATH = "/home/jonatan.enes/BlockchainServerless/scripts"
HOST_1 = "10.10.255.232"
ORCHESTRATOR_URL = "{0}:5000".format(HOST_1)

# MinIO configuration
minio_endpoint = "{0}:9000".format(HOST_1)
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
    return requests.get(url="http://{0}/user/{1}".format(ORCHESTRATOR_URL, user_name)).json()


def data_in_bucket_path(bucket, path):
    try:
        return minio_client.list_objects(bucket, prefix=path)
    except S3Error as e:
        print(f"Error listing files for path {0} in bucket {1}".format(path, bucket))
        raise e


def data_present_in_input(bucket, path):
    objects = data_in_bucket_path(bucket, path)
    # print("-------------")
    # print("{0}/{1}".format(bucket, path))
    i = 0
    for obj in objects:
        # print(obj.object_name)
        i += 1
    # print("-------------")
    if i > 1:
        return True
    else:
        return False


def start_container(bucket):
    subprocess.run(["bash", "{0}/tasks/{1}/start_container.sh".format(SCRIPTS_BASE_PATH, bucket)])


def stop_container(bucket):
    subprocess.run(["bash", "{0}/tasks/{1}/stop_container.sh".format(SCRIPTS_BASE_PATH, bucket)])


def run_new_task(bucket):
    objects = data_in_bucket_path(bucket, "/input")
    next(objects)  # First one is the directory
    new_task = next(objects).object_name
    new_task = new_task.replace("/input", "")
    print("Will run new task of type {0} with file '{1}'".format(bucket, new_task))
    command = ["bash", "{0}/tasks/{1}/process_task.sh".format(SCRIPTS_BASE_PATH, bucket), new_task]
    worker_process = Process(target=run_in_worker_process, args=(command,))
    worker_process.start()


def get_user(user_name):
    return get_user_info(user_name)

def get_user_status(user_info):
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
    print("User status is --> current: {0}, min_balance: {1}, max_debt: {2}, --> {3}".format(user_balance, user_min_balance,
                                                                                         user_max_debt, status))
    return status


def run_in_worker_process(command):
    subprocess.run(command)

def print_status_message(message, cond):
    if cond:
        print("{0}: YES".format(message))
    else:
        print("{0}: NO".format(message))

def print_user_status(user_status):
    if user_status == "normal":
        print("Enough credit, can run unrestricted, start tasks and containers")
    elif user_status == "broke":
        print("Scarce credit, can run unrestricted, start tasks and containers")
    elif user_status == "indebt":
        print("Debt, restricted execution, can't start tasks or containers")
    elif user_status == "scammer":
        print("Heavy Debt, stopping container")


if __name__ == '__main__':
    user_name = "user0"
    cont = "cont0"
    bucket = "stress"

    while True:
        container_running = container_is_running(cont)
        data_in_input = data_present_in_input(bucket, "input/")
        data_in_processing = data_present_in_input(bucket, "processing/")
        print_status_message("Container running", container_running)
        print_status_message("Data in input", data_in_input)
        print_status_message("Data in processing", data_in_processing)

        user = get_user(user_name)
        user_status = get_user_status(user)
        print_user_status(user_status)

        if container_running:
            if user_status in ["normal", "broke"]:
                if data_in_processing:
                    pass
                elif data_in_input:
                    print("Running new task")
                    run_new_task(bucket)
                else:
                    pass
            elif user_status in ["indebt"]:
                if data_in_processing:
                    pass
                elif data_in_input:
                    pass
                    print("Because user is in debt, no new tasks is started")
                else:
                    pass
            elif user_status in ["scammer"]:
                print("Stopping the running container")
                stop_container(bucket)
        else:
            if user_status in ["normal", "broke"]:
                if data_in_input:
                    print("Starting container")
                    start_container(bucket)
                    print("Running new task")
                    run_new_task(bucket)
                else:
                    pass
            elif user_status in ["indebt", "scammer"]:
                if data_in_input:
                    print("Because user is in debt, no task is executed and no container will be started")
                else:
                    pass
        print("----------")
        time.sleep(5)
