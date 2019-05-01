import hug
import os
import subprocess
import sys

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
    run_command("echo 'on 0' | cec-client RPI -s -d 1", shell=True)
    run_command("echo 'as' | cec-client RPI -s -d 1", shell=True)
    run_command("chromium-browser --start-fullscreen {0}".format(url),
                env={"DISPLAY": ":0.0"}, shell=True, background=True)
    sys.stdout.flush()  # Make sure print/stdout commands show up in systemd logs
    return {'message': 'URL:{0}'.format(url)}
