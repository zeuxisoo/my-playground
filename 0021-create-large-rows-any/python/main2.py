#!/usr/bin/env python

from io import StringIO
import asyncio
import shutil
import time

MAX_ROW = 1_000
CHUNK_ROW = 100

async def create_insert_statements(start: int, end: int) -> list[str]:
    statements = []
    for i in range(start, end):
        micro_time = int(time.time() * 1_000_000)
        statements.append(f"insert into table (id, a, b, t) values ({i}, 1, 2, {micro_time});\n")
    return statements

async def main() -> None:
    print('Gen ...')

    tasks = []
    for i in range(0, MAX_ROW, CHUNK_ROW):
        print(f"Sending {i}..{i + CHUNK_ROW}")

        tasks.append(
            asyncio.create_task(create_insert_statements(i, i + CHUNK_ROW))
        )

    str_io = StringIO()
    for task in tasks:
        str_io.write(''.join(await task))

    with open('./insert2.txt', 'w+') as f:
        str_io.seek(0)
        shutil.copyfileobj(str_io, f)

if __name__ == "__main__":
    asyncio.run(main())
