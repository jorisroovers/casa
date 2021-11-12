#!/usr/bin/env python
# Special thanks to this kind sir:
# https://gist.github.com/lorin/4cae51e123b596d5c60d
# Adapted from Mark Mandel's implementation
# https://github.com/ansible/ansible/blob/devel/plugins/inventory/vagrant.py
import argparse
import json
import paramiko
import subprocess
import sys


def parse_args():
    parser = argparse.ArgumentParser(description="Vagrant inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    return parser.parse_args()


def list_running_hosts():
    cmd = "vagrant status --machine-readable"
    status = subprocess.check_output(cmd.split()).rstrip()
    # Decode output in Python 3: See https://stackoverflow.com/a/24638593/381010
    if (sys.version_info.major == 3): 
        status = status.decode(sys.stdout.encoding)
    hosts = []
    for line in status.split('\n'):
        (_, host, key, value) = line.split(',', 3)
        if key == 'state' and value == 'running':
            hosts.append(host)
    return hosts


def get_host_details(host):
    cmd = "vagrant ssh-config {}".format(host)
    p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    config = paramiko.SSHConfig()
    stdout = p.stdout
    if (sys.version_info.major == 3): 
        stdout = p.stdout.read().decode(sys.stdout.encoding).split('\n')
    config.parse(stdout)
    c = config.lookup(host)
    return {'ansible_ssh_host': c['hostname'],
            'ansible_ssh_port': c['port'],
            'ansible_ssh_user': c['user'],
            'ansible_ssh_private_key_file': c['identityfile'][0],
            'ansible_ssh_common_args':'-o StrictHostKeyChecking=no' }


def main():
    args = parse_args()
    if args.list:
        hosts = list_running_hosts()
        json.dump({'vagrant': hosts}, sys.stdout)
    else:
        details = get_host_details(args.host)
        json.dump(details, sys.stdout)


if __name__ == '__main__':
    main()
