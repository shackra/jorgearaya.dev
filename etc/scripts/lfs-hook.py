#!/usr/bin/env python

import argparse
from os import path
import subprocess

lfs_script = 'git lfs %s "$@"'

parser = argparse.ArgumentParser(
    description="A simple script that installs git lfs hook"
)
parser.add_argument(
    "--stage", help="Specify the stage where to add the git lfs part", required=True
)

args = parser.parse_args()

git_command = subprocess.run(
    ["git", "rev-parse", "--path-format=absolute", "--git-common-dir"],
    check=True,
    capture_output=True,
    text=True,
)
git_common_dir = git_command.stdout.strip()

stage_location = path.join(git_common_dir, "hooks", args.stage)

if path.exists(stage_location):
    # check if the script was already installed
    with open(stage_location, "r") as file:
        for line in file:
            if line.startswith('git lfs %s "$@"' % args.stage):
                exit(0)  # nothing else to do

    with open(stage_location, "a") as file:
        file.write(lfs_script % args.stage)
else:
    with open(stage_location, "w") as file:
        file.write("#!/usr/bin/env bash")
        file.write(lfs_script % args.stage)
