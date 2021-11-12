import hug
import os
import subprocess
import sys
from time import sleep

authentication = hug.authentication.basic(hug.authentication.verify(os.environ['USERNAME'], os.environ['PASSWORD']))


def run_command(cmd, shell=False, background=False, env=None):
    if env is None:
        env_dict = {}
    else:
        env_dict = env

    kwargs = {"shell": shell, "env": env_dict}
    if background:
        subprocess.Popen(cmd, **kwargs)
    else:
        kwargs["stdout"] = subprocess.PIPE
        process = subprocess.Popen(cmd, **kwargs)
        output = process.stdout.readlines()
        print(output)


@hug.get(requires=authentication)
@hug.local()
def show_url(url: hug.types.text):
    """Show URL in chromium-browser """
    # Kill existing chrome session
    run_command("sudo pkill -f chromium", shell=True)

    # Clear chromium cache
    run_command("sudo rm -rf /home/pi/.cache/chromium/Default", shell=True, background=True)

    # Turn on TV
    run_command("echo 'on 0' | cec-client RPI -s -d 1", shell=True)

    # Switch input to RPI after waiting 5 sec, this allows the TV to turn on and start waiting for input
    # Note that TV will by default turn onto the input it was set to when turned off
    # Had some issues with this in the past, not sure why.
    sleep(5)
    run_command("echo 'as' | cec-client RPI -s -d 1", shell=True)

    # Show chromium-browser for user pi (doesn't work for other users right now)
    run_command("sudo -u pi chromium-browser --aggressive-cache-discard --kiosk --app {0}".format(url),
                env={"DISPLAY": ":0.0"}, shell=True, background=True)

    sys.stdout.flush()  # Make sure print/stdout commands show up in systemd logs
    return {'message': 'Opened URL:{0}'.format(url)}
