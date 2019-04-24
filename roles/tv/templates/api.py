import hug
import os

authentication = hug.authentication.basic(hug.authentication.verify(os.environ['USERNAME'], os.environ['PASSWORD']))


def run_command(cmd):
    myCmd = cmd
    output = os.system(myCmd)
    print(output)


@hug.get(requires=authentication)
@hug.local()
def show_url(url: hug.types.text):
    """Show URL in chromium-browser """
    run_command("echo 'on 0' | cec-client RPI -s -d 1")
    run_command("echo 'as' | cec-client RPI -s -d 1")
    return {'message': 'URL:{0}'.format(url)}
