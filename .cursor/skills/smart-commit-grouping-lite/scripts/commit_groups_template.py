#!/usr/bin/env python3
"""Template for commit_groups_<scope>.py. Copy to repo root and fill COMMITS."""

import subprocess
import sys

# fmt: off
COMMITS = [
    {
        "message": "<type>(<scope>): <description>",
        "files": ["path/to/file.py"],
    },
]
# fmt: on


def git(cmd: str, cwd: str) -> str:
    result = subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"\nERROR running: {cmd}\n{result.stderr}")
        sys.exit(1)
    return result.stdout.strip()


def get_repo_root() -> str:
    result = subprocess.run(
        "git rev-parse --show-toplevel", shell=True, capture_output=True, text=True
    )
    if result.returncode != 0:
        print("ERROR: not inside a git repository")
        sys.exit(1)
    return result.stdout.strip()


def print_plan() -> None:
    print("\n" + "=" * 72)
    print("PROPOSED COMMIT GROUPS")
    print("=" * 72)
    for i, commit in enumerate(COMMITS, 1):
        print(f"\n  [{i}] {commit['message']}")
        for f in commit["files"]:
            print(f"       {f}")
    total = sum(len(c["files"]) for c in COMMITS)
    print(f"\n  {len(COMMITS)} commits  |  {total} files\n" + "=" * 72)


def execute_commits(repo_root: str) -> None:
    git("git reset HEAD", repo_root)
    for i, commit in enumerate(COMMITS, 1):
        files = " ".join(f'"{f}"' for f in commit["files"])
        print(f"\n[{i}/{len(COMMITS)}] {commit['message']}")
        git(f"git add -- {files}", repo_root)
        git(f'git commit -m "{commit["message"]}"', repo_root)
    print("\n" + git(f"git log --oneline -{len(COMMITS)}", repo_root))


if __name__ == "__main__":
    repo_root = get_repo_root()
    print_plan()
    if "--exec" in sys.argv:
        if input("\nExecute these commits? [y/N] ").strip().lower() == "y":
            execute_commits(repo_root)
        else:
            print("Aborted.")
    else:
        print("\nRun with --exec to execute the commits.")
