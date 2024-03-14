from src.common.config import OpenTSDBConfig, MongoDBConfig
from src.opentsdb import bdwatchdog
from TimestampsSnitch.src.mongodb.mongodb_agent import MongoDBTimestampAgent
import matplotlib.pyplot as plt
import numpy as np


def find_first_tuple_with_value(data, target_value):
    for timestamp, value in data:
        if value >= target_value:
            return timestamp, value
    return None  # If no matching tuple is found


def get_time_taken(tuples, value):
    match = find_first_tuple_with_value(tuples, value)
    time_sent = (value - 1) * 90
    time_transfered = match[0]
    return time_transfered - time_sent


bdw = bdwatchdog.BDWatchdog(OpenTSDBConfig())
mongoDBConfig = MongoDBConfig()
timestampingAgent = MongoDBTimestampAgent(mongoDBConfig.get_config_as_dict())


def get_exp_times(experiment_name):
    experiment = timestampingAgent.get_experiment(experiment_name, mongoDBConfig.get_username())
    start, end = experiment["start_time"], experiment["end_time"]
    timeseries = bdw.get_timeseries("user0", start, end, [('user.accounting.coins', 'user')], downsample=5)["user.accounting.coins"]

    # Convert the time stamps to times relative to 0 (basetime)
    basetime = int(list(timeseries.keys())[0])
    times = list(map(lambda point: int(point) - basetime, timeseries))
    # Convert the coin values to relative to 0
    basecoins = int(list(timeseries.values())[0])
    coins = list(map(lambda point: int(point) - basecoins, timeseries.values()))

    tuples = zip(times, coins)

    times = list()
    for n in range(1, max(coins)):
        time_taken = get_time_taken(tuples, n)
        times.append(time_taken)
    print("Experiment {0} has {1} transactions".format(experiment_name, len(times)))
    return times

times = list()
times += get_exp_times("GRC_EXP_1")
times += get_exp_times("GRC_EXP_2")
times += get_exp_times("GRC_EXP_3")
print("Total transactions retrieved {0}".format(len(times)))
transactions_done = len(times)

q1 = np.quantile(times, 0.25)
q2 = np.quantile(times, 0.50)
q3 = np.quantile(times, 0.75)
q90 = np.quantile(times, 0.90)

fig, axes = plt.subplots(nrows=2, ncols=1, sharex=True, figsize=(8, 2.9), gridspec_kw={'height_ratios': [1, 3]})

counts, bins = np.histogram(times, bins=40)
axes[1].hist(bins[:-1], bins, weights=counts)

axes[1].annotate(int(q1), xy=(q1, max(counts) + 25), ha='center', fontsize=11)
axes[1].annotate(int(q2), xy=(q2, max(counts) + 25), ha='center', fontsize=11)
axes[1].annotate(int(q3), xy=(q3, max(counts) + 25), ha='center', fontsize=11)
axes[1].annotate(int(q90), xy=(q90, max(counts) + 25), ha='center', fontsize=11)
axes[1].annotate("N={0}".format(transactions_done), xy=(max(times) - 50, max(counts) + 8), ha='center', fontsize=12, bbox=dict(facecolor='none', edgecolor='red'))

axes[1].axvline(q1, color='red', alpha=.6, linewidth=2, linestyle="-.", ymax=0.92)
axes[1].axvline(q2, color='orange', alpha=.6, linewidth=2, linestyle="--", ymax=0.92)
axes[1].axvline(q3, color='green', alpha=.6, linewidth=2, linestyle="-", ymax=0.92)
axes[1].set_xlabel("Transaction time (s)", fontsize=12)
axes[1].set_ylabel("# Transactions", fontsize=12)
axes[1].spines[['right', 'top']].set_visible(False)
axes[1].set_ylim(0, 200)

axes[0].boxplot(times, 0, vert=False, widths=0.15, whis=(10, 90))
axes[0].get_yaxis().set_visible(False)
axes[0].axis('off')
axes[0].margins(y=-0.30)

plt.subplots_adjust(hspace=0)
fig.savefig("grc_transactions.png", bbox_inches='tight', pad_inches=0.01, format="png")
