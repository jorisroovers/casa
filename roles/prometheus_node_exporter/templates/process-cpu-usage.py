#!/usr/bin/python3
# Collects processes by name, and aggregates their CPU usage, exposes them as prometheus metrics
# TODO: obfuscate passwords in env scripts

import subprocess
import collections
import datetime
import re

########################################################################################################################
# CONFIG
PROM_FILE = "{{node_exporter_textfile_exports}}/process-cpu-usage.prom"
# PROCESS_BLACKLIST_REGEX = [re.compile("^\["), re.compile("^docker-containerd-shim")]
PROCESS_BLACKLIST_REGEX = []

print("****** {0} ******".format(datetime.datetime.now()))
########################################################################################################################
# Get processes, group by process name, collect aggregate CPU usage

processes = subprocess.Popen("ps aux", shell=True, stdout=subprocess.PIPE).stdout.readlines()
process_map = collections.OrderedDict()
for process_line in processes[1:]:
    process_parts = process_line.decode("UTF-8").split()
    # pname = process_parts[10]
    pname = " ".join(process_parts[10:])
    try:
        for regex in PROCESS_BLACKLIST_REGEX:
            if regex.match(pname):
                # We need this ugly construct with exceptions to continue the outer loop has python
                # has no support for loop-labels
                raise Exception("Blacklisted process")
    except:
        continue

    pcpu = float(process_parts[2])
    existing_cpu = process_map.get(pname, 0.0)
    process_map[pname] = existing_cpu + pcpu

# Sort by highest CPU usage
sorted_process_map = sorted(process_map.items(), key=lambda x: x[1], reverse=True)

########################################################################################################################
# Export metrics to file

print("Exporting process cpu usage to prometheus ({0})...".format(PROM_FILE))

# Write file header to .prom file
fh = open(PROM_FILE, "w")
fh.write("# HELP process_cpu_usage CPU usage for all processes running on the system\n")
fh.write("# TYPE process_cpu_usage gauge\n")

for pname, cpu in sorted_process_map:
    # {# 'raw' comment line needed for ansible template #} {% raw %}
    prom_line = 'process_cpu_usage{{process="{0}"}} {1}\n'.format(pname, cpu)
    # {# 'endraw' comment line needed for ansible template #} {% endraw %}

    # print(prom_line,)
    fh.write(prom_line)

fh.close()
print("DONE")
