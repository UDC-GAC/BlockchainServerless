import os
import time

import requests
import subprocess
from minio import Minio
from minio.error import S3Error
from minio.commonconfig import CopySource
from multiprocessing import Process, Value

from termcolor import colored


def myprint(message):
    #logging.info(message)
    print("[{0}]: {1}".format(get_time_now_string(), message))

def printerr(message):
    #logging.error(message)
    print("[{0}]: {1}".format(get_time_now_string(), colored(message, "red")))


def get_time_now_string():
    return str(time.strftime("%H:%M:%S", time.localtime()))


worker_process = None
SCRIPTS_BASE_PATH = "/home/jonatan.enes/BlockchainServerless/scripts"
if "HOST_1" not in os.environ:
    print("Variable 'HOST_1' (where MinIO is deployed) not configured in environment, set it accordingly")
    exit(1)
else:
    HOST_1 = os.environ["HOST_1"]

ORCHESTRATOR_URL = "{0}:5000".format(HOST_1)

username = "user0"
contname = "cont0"
bucket = "stress"
images = {"stress": "experiment"}
cont_last_finished_task = Value('i', -1)

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
        objects = minio_client.list_objects(bucket, prefix=path)
        objects_list = list()
        for obj in objects:
            if obj.object_name == path:
                continue  # Skip this one (usually the first one) as it is the dir
            objects_list.append(obj)
        return objects_list
    except S3Error as e:
        printerr("Error listing files for path {0} in bucket {1}".format(path, bucket))
        return []


def data_present_in_path(bucket, path):
    objects = data_in_bucket_path(bucket, path)
    if objects:
        return True
    else:
        return False


def start_container(bucket):
    p = subprocess.run(["bash", "{0}/tasks/common/start_container.sh".format(SCRIPTS_BASE_PATH), contname, images[bucket]])
    return p.returncode == 0


def stop_container(bucket):
    subprocess.run(["bash", "{0}/tasks/common/stop_container.sh".format(SCRIPTS_BASE_PATH), contname, images[bucket]])

def run_in_worker_process(command, taskname, bucket, cont_last_finished_task):
    logname = "out-task-{0}".format(taskname)
    logfile = "/tmp/{0}".format(logname)
    with open(logfile, "w") as outfile:
        p = subprocess.run(command, stdout=outfile)
        if p.returncode != 0:
            printerr("There was an error running user's script for task '{0}' of type '{1}'".format(taskname, bucket))
            printerr("Moving back the file to 'input'")
            move_task_between_dirs(bucket, "processing", "input", taskname)
        else:
            myprint("Task for '{0}' finished successfully".format(taskname))
            myprint("Moving file to 'output'")
            move_task_between_dirs(bucket, "processing", "output", taskname)
    minio_client.fput_object(bucket, "logs/{0}".format(logname), logfile)
    cont_last_finished_task.value = int(time.time())

def check_container_timeout(bucket, contname):
    TIMEOUT = 60
    idle_time = int(time.time()) - cont_last_finished_task.value
    if idle_time > TIMEOUT:
        myprint("Container {0} has exceeded timeout ({1}), stopping".format(contname, TIMEOUT))
        stop_container(bucket)
    else:
        myprint("Container {0} has now been running for {1} idle seconds".format(contname, idle_time))

def run_new_task(bucket):
    objects = data_in_bucket_path(bucket, "input/")

    # Get the file to process (task)
    taskname = objects[0].object_name.replace("input/", "")
    myprint("Will run new task of type '{0}' with file '{1}'".format(bucket, taskname))

    # Get the script to run with the task
    local_path_script = "/tmp/{0}-process_task.sh".format(bucket)
    try:
        minio_client.fget_object(bucket, "utils/process_task.sh", local_path_script)
    except S3Error:
        printerr("Could not retrieve script to process task of type {0}".format(bucket))
        printerr("Script should be named '{0}' and be located in '{1}'".format("process_task.sh", "{0}/utils/".format(bucket)))
        return

    # Move the file to process from input to processing
    move_task_between_dirs(bucket, "input", "processing", taskname)

    # Download the file locally
    local_path_taskfile = "/tmp/{0}".format(taskname)
    minio_client.fget_object(bucket, "processing/{0}".format(taskname), local_path_taskfile)

    # Run the user's script with the file and inside a container
    command = ["sudo", "apptainer", "exec", "instance://{0}".format(contname), "bash", local_path_script, local_path_taskfile]

    # Run with a process in background
    worker_process = Process(target=run_in_worker_process, args=(command, taskname, bucket, cont_last_finished_task))
    worker_process.start()


def get_user(user_name):
    return get_user_info(user_name)


def get_user_status(user_info):
    user_balance = user_info["accounting"]["coins"]
    user_max_debt = user_info["accounting"]["max_debt"]
    user_min_balance = user_info["accounting"]["min_balance"]
    if user_balance > user_min_balance and user_balance > 0:
        status = "normal"
    elif user_balance <= user_min_balance and user_balance >= 0:
        status = "broke"
    elif user_balance < 0 and user_balance > user_max_debt:
        status = "indebt"
    elif user_balance < 0 and user_balance < user_max_debt:
        status = "scammer"
    else:
        status = "unknown"
    return status


def move_task_between_dirs(bucket, dir1, dir2, filename):
    try:
        source = "{0}/{1}".format(dir1, filename)
        minio_client.copy_object(
            bucket, "{0}/{1}".format(dir2, filename),
            CopySource(bucket, source))
        minio_client.remove_object(bucket, source)
    except (ValueError, S3Error):
        printerr("Error moving the file {0}".format(filename))

def move_tasks_processing_to_input(bucket):
    tasks = data_in_bucket_path(bucket, "processing/")
    for task_object in tasks:
        filename=task_object.object_name.replace("processing/", "")
        print("Moving {0}".format(filename))
        move_task_between_dirs(bucket, "processing", "input", filename)

def print_status_message(message, cond):
    if cond:
        myprint("{0}: {1}".format(message, colored("YES", "green")))
    else:
        myprint("{0}: {1}".format(message, colored("NO", "red")))


def print_user_info(user, user_status):
    us_acc = user["accounting"]
    us_policy = us_acc["policy"]
    policy_colors = {"greedy": "yellow", "conservative": "blue"}

    myprint("User balances are / current: {0} / min_balance: {1} / max_debt: {2} / policy '{3}'".format(
        us_acc["coins"], us_acc["min_balance"], us_acc["max_debt"], colored(us_policy, policy_colors[us_policy])))

    if user_status == "normal":
        myprint("[{0}] Enough credit, can run unrestricted, start tasks and containers".format(colored("Normal", "cyan")))
    elif user_status == "broke" and us_acc["policy"] == "greedy":
        myprint("[{0}] Scarce credit with 'greedy' policy, can run unrestricted, start tasks and containers".format(colored("Broke", "yellow")))
    elif user_status == "broke" and us_acc["policy"] == "conservative":
        myprint("[{0}] Scarce credit with 'conservative' policy, can run unrestricted, can't start tasks or containers".format(colored("Broke", "yellow")))
    elif user_status == "indebt":
        myprint("[{0}] Debt, restricted execution, can't start tasks or containers".format(colored("Indebt", "light_red")))
    elif user_status == "scammer":
        myprint("[{0}] Heavy Debt, nothing allowed, if running stop the container".format(colored("Scammer", "red")))
    else:
        myprint("[{0}] User status unknown".format(user_status))


def start_container_process(bucket):
    myprint("Starting container")
    success = start_container(bucket)
    if success:
        myprint("Running new task")
        run_new_task(bucket)
    else:
        printerr("Could not start the container")


if __name__ == '__main__':
    while True:
        container_running = container_is_running(contname)
        data_in_input = data_present_in_path(bucket, "input/")
        data_in_processing = data_present_in_path(bucket, "processing/")
        print_status_message("Container running", container_running)
        print_status_message("Data in input", data_in_input)
        print_status_message("Data in processing", data_in_processing)

        user = get_user(username)
        user_status = get_user_status(user)
        print_user_info(user, user_status)
        user_policy = user["accounting"]["policy"]

        if container_running:
            if user_status in ["normal"]:
                if data_in_processing:
                    pass
                elif data_in_input:
                    myprint("Running new task")
                    run_new_task(bucket)
                else:
                    check_container_timeout(bucket, contname)
            elif user_status in ["broke"]:
                if data_in_processing:
                    pass
                elif data_in_input:
                    if user_policy == "greedy":
                        myprint("Running new task")
                        run_new_task(bucket)
                    else:
                        myprint("User policy does not allow to start a new task")
                else:
                    check_container_timeout(bucket, contname)
            elif user_status in ["indebt"]:
                if data_in_processing:
                    pass
                elif data_in_input:
                    myprint("Because user is in debt, no new tasks is started")
                else:
                    check_container_timeout(bucket, contname)
            elif user_status in ["scammer"]:
                myprint("Stopping the running container")
                stop_container(bucket)
        else:
            if data_in_processing:
              myprint("There is data allegedly being processed but no container is up")
              myprint("Returning tasks from 'processing' to 'input'")
              move_tasks_processing_to_input(bucket)
            elif user_status in ["normal"]:
                if data_in_input:
                    start_container_process(bucket)
                else:
                    pass
            elif user_status in ["broke"]:
                if data_in_input:
                    if user_policy == "greedy":
                        start_container_process(bucket)
                    else:
                        myprint("User policy does not allow to start a container")
                else:
                    pass
            elif user_status in ["indebt", "scammer"]:
                if data_in_input:
                    myprint("Because user is in debt, no task is executed and no container will be started")
                else:
                    pass
        myprint("----------")
        time.sleep(5)
