#!/usr/bin/env python

from concurrent import futures
import random
import string
import time

MAX_ROW = 1_000
CHUNK_ROW = 100

def create_insert_statements(start: int, end: int) -> list[str]:
    statements = []
    for i in range(start, end):
        micro_time = int(time.time() * 1_000_000)
        statements.append(f"insert into table (id, a, b, t) values ({i}, 1, 2, {micro_time});\n")
    return statements

def main() -> None:
    print('Gen ...')

    with open('./insert.txt', 'w') as file:
        with futures.ThreadPoolExecutor() as executor:
            tasks = []

            for i in range(0, MAX_ROW, CHUNK_ROW):
                print(f"Sending {i}..{i + CHUNK_ROW}")
                tasks.append(executor.submit(create_insert_statements, i, i + CHUNK_ROW))

            for task in futures.as_completed(tasks):
                file.writelines(task.result())

if __name__ == "__main__":
    main()
