#!/usr/bin/env python3

import os
import sys
import pickle
import argparse
from binascii import crc32
from functools import reduce
from hashlib import sha256
from pathlib import Path
from typing import Union
from pprint import pprint

# DiffDict = dict[str, Union[str, dict[str, str], list[str]]]
DiffDict = dict[str, Union[str, list[str]]]

STORAGE_PATH=Path("./storage").absolute()

def crc32_file(path: str) -> int:
    with open(path, 'rb') as f:
        checksum = 0
        while (chunk := f.read(1024)):
            checksum = crc32(chunk, checksum)
        return checksum

def crc32_directory(path: str, file_sums: list[int]) -> int:
    if not file_sums:
        return crc32(bytes(path, 'utf-8'))
    return reduce(lambda i, j: int(i) ^ int(j), file_sums)

def to_hex(value: int) -> str:
    return hex(value) # f"{value:#010x}"

def sum_directory(path: str) -> dict[str, str]:
    sums: dict[str, str] = {}
    for root, dirs, files in os.walk(path):
        root_file_sums = []

        for file in files:
            file_path = str(Path(root).joinpath(file))
            crc32_sum = crc32_file(file_path)
            sums[file_path] = to_hex(crc32_sum)

            root_file_sums.append(crc32_sum)

        sums[root] = to_hex(crc32_directory(root, root_file_sums))
    return sums

def get_project_storage_path(path: str) -> Path:
    project_hash = sha256(bytes(path, 'utf-8')).hexdigest()[:10]
    storage_path = Path(STORAGE_PATH).joinpath(project_hash)
    return storage_path

def assert_directory_exists(path: str) -> None:
    directory_path = Path(path).absolute()

    if not directory_path.exists():
        print("[Error] Target directory does not exists")
        print(f"------ {directory_path}")
        sys.exit(0)

def diff_dicts(first: dict[str, str], second: dict[str, str]) -> DiffDict:
    changed = []
    deleted = []
    inserted = []

    for key in first:
        if key not in second:
            deleted.append(key)
        elif first[key] != second[key]:
            # changed[key] = {'from': first[key], 'to': second[key]} # use first DiffDict
            changed.append(key)

    for key in second:
        if key not in first:
            # inserted[key] = dict2[key]
            inserted.append(key)

    # may sort directory first
    # changed.sort()
    # deleted.sort()
    # inserted.sort()

    return {
        'changed': changed,
        'deleted': deleted,
        'inserted': inserted
    }

def dump(project_path: str):
    assert_directory_exists(project_path)

    project_storage_path = get_project_storage_path(project_path)
    project_default_sum_path = project_storage_path.joinpath('sum-default.pickle')

    if not project_storage_path.exists():
        project_storage_path.mkdir()

    checksums = sum_directory(project_path)
    checksum_data = pickle.dumps(checksums)

    with open(project_default_sum_path, 'wb+') as f:
        f.write(checksum_data)

    with open(project_default_sum_path, 'rb') as f:
        pickle.loads(f.read())

    print("[OK] Target directory dump succeeded")
    print(f"---- {project_storage_path}")

def diff(project_path: str):
    assert_directory_exists(project_path)

    project_storage_path = get_project_storage_path(project_path)
    project_default_sum_path = project_storage_path.joinpath('sum-default.pickle')

    if not project_default_sum_path.exists():
        print("[Error] Missing checksum file in target directory, Please use `--dump` to create default checksum file first")
        print(f"------ {project_default_sum_path}")
        sys.exit(0)

    default_sum_file = open(project_default_sum_path, 'rb')
    default_checksums = pickle.loads(default_sum_file.read())
    default_sum_file.close()

    current_checksums = sum_directory(project_path)

    diff_checksums = diff_dicts(default_checksums, current_checksums)

    pprint(diff_checksums)
    pass

def main():
    raise ValueError('[ERROR] Unknown command action')

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", help="target directory path", type=str, required=True)
    parser.add_argument("--dump", help="dump the checksums of directory", action="store_true")
    parser.add_argument("--diff", help="diff the checksums of directory", action="store_true")
    args = parser.parse_args()

    if args.dump:
        dump(args.path)
    elif args.diff:
        diff(args.path)
    else:
        main()
