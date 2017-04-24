import os, shutil

from invoke import task


@task
def noobs(ctx, docs=False):
    # 1. Only keep os/Raspbian
    noobs_dir = os.path.abspath("NOOBS_v2_4_0")
    print "1. Only keep {}/os/Raspbian...".format(noobs_dir)
    os_dir = os.path.join(noobs_dir, "os")
    os_dirs = os.listdir(os_dir)
    for file in os_dirs:
        if file not in ["Raspbian", ".DS_Store"]:
            shutil.rmtree(os.path.join(os_dir, file))
    print "DONE"

    # 2. Modify recovery.cmdline
    print "2. Modify...".format(noobs_dir)
    recovery_file = os.path.join(noobs_dir, "recovery.cmdline")
    contents = open(recovery_file).readline()
    if not contents.endswith("silentinstall\n"):
        contents = contents.replace("\n", "") + " silentinstall\n"
        open(recovery_file, "w").write(contents)

    print "DONE"
