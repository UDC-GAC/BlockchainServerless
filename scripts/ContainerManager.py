import glob
import logging
import multiprocessing
import os
import shutil
import time
from pathlib import Path
from xml.etree.ElementTree import ParseError

import requests
import subprocess
from minio import Minio
from minio.error import S3Error
from minio.commonconfig import CopySource
from multiprocessing import Process, Value

from termcolor import colored
import src.StateDatabase.opentsdb as opentsdb
opentsdb_handler = opentsdb.OpenTSDBServer(opentsdb_url="193.144.50.38", opentsdb_port="4242")

def myprint(message):
    message_with_time = "[{0}]: {1}".format(get_time_now_string(), message)
    logging.info(message_with_time)
    print(message_with_time)


def printerr(message):
    message_with_time = "[{0}]: {1}".format(get_time_now_string(), colored(message, "red"))
    logging.info(message_with_time)
    print(message_with_time)


def get_time_now_string():
    return str(time.strftime("%H:%M:%S", time.localtime()))


worker_process = None
SCRIPTS_BASE_PATH = "/home/jonatan.enes/BlockchainServerless/scripts/tasks/common"
if "HOST_1" not in os.environ:
    print("Variable 'HOST_1' (where MinIO is deployed) not configured in environment, set it accordingly")
    exit(1)
else:
    HOST_1 = os.environ["HOST_1"]

ORCHESTRATOR_URL = "{0}:5000".format(HOST_1)

LOCAL_TMP_DIR = "/tmp/jonatan.enes"

USERNAME = "user0"
images = {"stress": "stress", "genomics": "genomics", "transcode": "transcode"}
cont_last_finished_task = Value('i', int(time.time()))
task_has_finished = multiprocessing.Manager().Lock()

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


def get_file_from_bucket(bucket, filename, local_path, override=False):
    if Path(local_path).exists():
        if override:
            os.remove(local_path) if os.path.exists(local_path) else None
        else:
            myprint("Object '{0}' already exists in '{1}'".format(filename, local_path))
            return True

    try:
        minio_client.fget_object(bucket, filename, local_path)
        return True
    except S3Error:
        printerr(
            "Could not retrieve file '{0}' from bucket '{1}' to be stored at {2}".format(filename, bucket, local_path))
        return False

def get_all_files_from_bucket(bucket, path, local_path):
    objects = data_in_bucket_path(bucket, path)
    for obj in objects:
        myprint(obj.object_name)
        object_name = obj.object_name.replace("staging/", "")
        if Path("{0}/{1}".format(local_path, object_name)).exists():
            myprint("Object '{0}' already exists in '{1}'".format(object_name, local_path))
        else:
            myprint("Downloading '{0}'".format(object_name))
            minio_client.fget_object(bucket, obj.object_name, "{0}/{1}".format(local_path, object_name))
            myprint("Finished")

def start_container(bucket, contname):
    local_stag_dir = "/scratch2/staging/{0}".format(bucket)
    myprint("Downloading all objects from 'staging' bucket dir to local staging dir in {0}".format(local_stag_dir))
    #shutil.rmtree(local_stag_dir, ignore_errors=True)
    Path(local_stag_dir).mkdir(parents=True, exist_ok=True)
    get_all_files_from_bucket(bucket, "staging/", local_stag_dir)

    image_name = "{0}.sif".format(images[bucket])
    local_path = "/scratch2/images"
    Path(local_path).mkdir(parents=True, exist_ok=True)
    local_image_path = "{0}/{1}".format(local_path, image_name)
    myprint("Downloading container image '{0}' from 'utils' bucket dir to local in {0}".format(image_name, local_image_path))
    bucket_path = "/utils/{0}".format(image_name)
    get_file_from_bucket(bucket, bucket_path, local_image_path, override=False)

    p = subprocess.run(["bash", "{0}/start_container.sh".format(SCRIPTS_BASE_PATH), contname, local_image_path, local_stag_dir])
    return p.returncode == 0


def stop_container(bucket):
    subprocess.run(["bash", "{0}/stop_container.sh".format(SCRIPTS_BASE_PATH), contname, images[bucket]])


def check_container_timeout(bucket, contname):
    DEFAULT_TIMEOUT = 60
    filepath = "{0}/{1}-timeout.txt".format(LOCAL_TMP_DIR, contname)
    success = get_file_from_bucket(bucket, "utils/timeout.txt", filepath, override=True)
    if success:
        with open(filepath) as f:
            try:
                timeout = int(float(f.readline()))
            except ValueError:
                printerr("Invalid value in file timeout.txt, using default timeout of {0}".format(DEFAULT_TIMEOUT))
                timeout = DEFAULT_TIMEOUT
    else:
        printerr("Using default timeout of {0}".format(DEFAULT_TIMEOUT))
        timeout = DEFAULT_TIMEOUT

    idle_time = int(time.time()) - cont_last_finished_task.value
    if idle_time > timeout:
        myprint("Container {0} has exceeded timeout of {1}s, stopping".format(contname, timeout))
        stop_container(bucket)
    else:
        myprint("Container {0} has now been running for {1} idle seconds, timeout is {2}s".format(contname, idle_time,
                                                                                                  timeout))


def run_new_task(bucket):
    objects = data_in_bucket_path(bucket, "input/")

    # Get the file to process (task)
    taskname = objects[0].object_name.replace("input/", "")
    myprint("Will run new task of type '{0}' with file '{1}'".format(bucket, taskname))

    # Get the script to run with the task
    local_path_script = "{0}/{1}-process_task.sh".format(LOCAL_TMP_DIR, bucket)
    success = get_file_from_bucket(bucket, "utils/process_task.sh", local_path_script, override=True)
    if not success:
        printerr("Could not retrieve script to process task of type {0}".format(bucket))
        printerr("Script should be named '{0}' and be located in '{1}'".format("process_task.sh",
                                                                               "{0}/utils/".format(bucket)))
        return

    # Move the file to process from input to processing
    move_task_between_dirs(bucket, "input", "processing", taskname)

    # Download the file locally
    local_path_taskfile = "{0}/{1}".format(LOCAL_TMP_DIR, taskname)
    success = get_file_from_bucket(bucket, "processing/{0}".format(taskname), local_path_taskfile, override=True)
    if not success:
        printerr("Could not download the file data for the task")
        return

    local_output_path = "{0}/{1}/results".format(LOCAL_TMP_DIR, contname)
    shutil.rmtree(local_output_path, ignore_errors=True)
    Path(local_output_path).mkdir(parents=True, exist_ok=True)
    # Run the user's script with the file and inside a container
    command = ["sudo", "apptainer", "exec", "instance://{0}".format(contname), "bash", local_path_script,
               local_path_taskfile, local_output_path]

    # Run with a process in background
    worker_process = Process(target=run_in_worker_process,
                             args=(command, taskname, bucket, local_output_path, cont_last_finished_task))
    worker_process.start()


def copy_log_to_bucket(taskname):
    myprint("Copying the log of task '{0}' to the 'logs/' dir".format(taskname))
    logname = "out-task-{0}.txt".format(taskname)
    logfile = "/{0}/{1}".format(LOCAL_TMP_DIR, logname)
    minio_client.fput_object(bucket, "logs/{0}".format(logname), logfile)

def run_in_worker_process(command, taskname, bucket, local_output_path, cont_last_finished_task):
    #logname = "out-task-{0}-{1}.txt".format(taskname, int(time.time()))
    logname = "out-task-{0}.txt".format(taskname)
    logfile = "/{0}/{1}".format(LOCAL_TMP_DIR, logname)
    os.remove(logfile) if os.path.exists(logfile) else None
    with open(logfile, "w") as outfile:
        p = subprocess.run(command, stdout=outfile, stderr=outfile)
        task_has_finished.acquire()
        if p.returncode != 0:
            printerr("There was an error running user's script for task '{0}' of type '{1}'".format(taskname, bucket))
            printerr("Moving back the file to 'input'")
            move_task_between_dirs(bucket, "processing", "input", taskname)
        else:
            myprint("Task for '{0}' finished successfully".format(taskname))
            copy_log_to_bucket(taskname)
            cont_last_finished_task.value = int(time.time())
            myprint("Moving file to 'output'")
            myprint("----------")
            move_task_between_dirs(bucket, "processing", "output", taskname)
            myprint("Result files are:")
            for f in os.listdir(local_output_path):
                if os.path.isfile(os.path.join(local_output_path, f)):
                    filepath = os.path.join(local_output_path, f)
                    minio_client.fput_object(bucket, "results/{0}".format(f), filepath)
                    os.remove(filepath)
        task_has_finished.release()



def get_user(user_name):
    return get_user_info(user_name)


def get_user_status(user_info):
    user_balance = user_info["accounting"]["coins"]
    user_max_debt = user_info["accounting"]["max_debt"]
    user_min_balance = user_info["accounting"]["min_balance"]
    if user_balance > user_min_balance and user_balance > 0:
        status = "normal"
    elif user_balance <= user_min_balance and user_balance > 0:
        status = "broke"
    elif user_balance <= 0 and user_balance > user_max_debt:
        status = "indebt"
    elif user_balance < 0 and user_balance <= user_max_debt:
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
        filename = task_object.object_name.replace("processing/", "")
        myprint("Moving {0}".format(filename))
        move_task_between_dirs(bucket, "processing", "input", filename)


def persist_tasks_number(bucket, input_bucket, processing_bucket):
    def send_num_items(dir, value):
        ts = dict(
            metric="bucket.tasks.{0}".format(dir),
            value=value,
            timestamp=int(time.time()),
            tags={"bucket": bucket}
        )
        return ts
    docs = list()
    docs.append(send_num_items("input", len(input_bucket)))
    docs.append(send_num_items("processing", len(processing_bucket)))
    success, error = opentsdb_handler.send_json_documents(docs)
    if success:
        pass
    else:
        printerr("Couldn't send the time series for 'input' and 'processing' bucket tasks num")
        printerr(error)

def print_status_message(message, cond):
    if cond:
        if isinstance(cond, list):
            myprint("{0}: {1}".format(message, colored("YES ({0})".format(len(cond)), "green")))
        else:
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
        myprint(
            "[{0}] Enough credit, can run unrestricted, start tasks and containers".format(colored("Normal", "cyan")))
    elif user_status == "broke" and us_acc["policy"] == "greedy":
        myprint("[{0}] Scarce credit with 'greedy' policy, can run unrestricted, start tasks and containers".format(
            colored("Broke", "yellow")))
    elif user_status == "broke" and us_acc["policy"] == "conservative":
        myprint(
            "[{0}] Scarce credit with 'conservative' policy, can run unrestricted, can't start tasks or containers".format(
                colored("Broke", "yellow")))
    elif user_status == "indebt":
        myprint(
            "[{0}] Debt, restricted execution, can't start tasks or containers".format(colored("Indebt", "light_red")))
    elif user_status == "scammer":
        myprint("[{0}] Heavy Debt, nothing allowed, if running stop the container".format(colored("Scammer", "red")))
    else:
        myprint("[{0}] User status unknown".format(user_status))


def start_container_process(bucket, contname):
    myprint("Starting container")
    success = start_container(bucket, contname)
    if success:
        cont_last_finished_task.value = int(time.time())
        myprint("Running new task")
        run_new_task(bucket)
    else:
        printerr("Could not start the container")


FUNCTIONS = ["genomics"] # transcode, genomics

if __name__ == '__main__':
    logging.basicConfig(filename='manager.log', level=logging.INFO)

    while True:
        try:
            task_has_finished.acquire()
            user = get_user(USERNAME)
            try:
                user_status = get_user_status(user)
            except KeyError:
                printerr("Error retrieveing user accounting, skipping")
                time.sleep(5)
                continue
            print_user_info(user, user_status)
            user_policy = user["accounting"]["policy"]
            myprint("----------")

            for func in FUNCTIONS:
                myprint("Going to check function {0}".format(colored(func, "green")))
                contname = "{0}-cont".format(func)
                bucket = func
                container_running = container_is_running(contname)
                data_in_input = data_in_bucket_path(bucket, "input/")
                data_in_processing = data_in_bucket_path(bucket, "processing/")
                print_status_message("Container running", container_running)
                print_status_message("Data in input", data_in_input)
                print_status_message("Data in processing", data_in_processing)
                persist_tasks_number(bucket, data_in_input, data_in_processing)

                if container_running:
                    if user_status in ["normal"]:
                        if data_in_processing:
                            taskname = data_in_processing[0].object_name.replace("processing/", "")
                            copy_log_to_bucket(taskname)
                        elif data_in_input:
                            myprint("Running new task")
                            run_new_task(bucket)
                        else:
                            check_container_timeout(bucket, contname)
                    elif user_status in ["broke"]:
                        if data_in_processing:
                            taskname = data_in_processing[0].object_name.replace("processing/", "")
                            copy_log_to_bucket(taskname)
                        elif data_in_input:
                            if user_policy == "greedy":
                                myprint("Running new task")
                                run_new_task(bucket)
                            else:
                                myprint("User policy does not allow to start a new task, container will be checked for timeout")
                                check_container_timeout(bucket, contname)
                        else:
                            check_container_timeout(bucket, contname)
                    elif user_status in ["indebt"]:
                        if data_in_processing:
                            taskname = data_in_processing[0].object_name.replace("processing/", "")
                            copy_log_to_bucket(taskname)
                        elif data_in_input:
                            myprint("Because user is in debt, no new tasks are started and container is checked for timeout")
                            check_container_timeout(bucket, contname)
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
                            start_container_process(bucket, contname)
                        else:
                            pass
                    elif user_status in ["broke"]:
                        if data_in_input:
                            if user_policy == "greedy":
                                start_container_process(bucket, contname)
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
            myprint("Finished epoch\n")
            task_has_finished.release()
            time.sleep(5)
        except (ValueError, ParseError) as e:
            print(e)
            time.sleep(5)
