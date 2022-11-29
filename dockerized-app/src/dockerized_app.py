import logging
import signal
import time
import random
import os

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s.%(msecs)03d;%(levelname)s;%(message)s",
                    datefmt="%Y-%m-%d %H:%M:%S")
LOG = logging.getLogger(__file__)

SHUTDOWN = False


def exit_gracefully(self, *args):
    global SHUTDOWN
    LOG.info("Exit request, see ya!")
    SHUTDOWN = True


def show_metrics():
    """
    System load: 1.0 means that 1 process tried to use 100% of cpu all the time.
    For a machine with 1 core it should stay below 1,
    For a machine with 2 cores it should stay below 2 etc.
    """
    load1m, load5m, load15m = os.getloadavg()

    """
    Get stats of current machine, using 'free' utility. Saving almost all fields for simpler troubleshooting
    """
    cmd = 'free -b'
    data_line = os.popen(cmd).readlines()[1].split()[1:]
    total_memory, used_memory, free_memory, shared_memory, buff_cache_memory, available_memory = map(int, data_line)

    LOG.info("System stats...")
    print("Load")
    print(f"Load 1 minute: {load1m}")
    print(f"Load 5 minutes: {load5m}")
    print(f"Load 15 minutes: {load15m}")
    print()
    print("Memory")
    print(f"Total memory: {pretty_bytes(total_memory)}")
    print(f"Used memory: {pretty_bytes(used_memory)}")
    print(f"Free memory: {pretty_bytes(free_memory)}")
    print(f"Shared memory: {pretty_bytes(shared_memory)}")
    print(f"Buff,cache memory: {pretty_bytes(buff_cache_memory)}")
    print(f"Available memory: {pretty_bytes(available_memory)}")
    print(f"Available memory %: {round(used_memory / (used_memory + available_memory), 2)}")
    print()


def pretty_bytes(bytes):
    if bytes > 1_000_000:
        return f'{round(bytes / 1_000_000, 3)} MB'
    if bytes > 1_000:
        return f'{round(bytes / 1_000, 3)} KB'

    return f'{bytes} B'


signal.signal(signal.SIGINT, exit_gracefully)
signal.signal(signal.SIGTERM, exit_gracefully)

while not SHUTDOWN:
    show_metrics()

    to_sleep = random.randrange(5, 20)
    LOG.info(f"Sleeping random {to_sleep}s...")
    
    time.sleep(to_sleep)
