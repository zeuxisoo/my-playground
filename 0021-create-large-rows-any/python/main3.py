#!/usr/bin/env python

import asyncio
import time
# import shutil
# from io import StringIO
from typing import Any, AsyncGenerator

MAX_ROW = 1_000
CHUNK_ROW = 100

async def create_insert_statements(start: int, end: int) -> AsyncGenerator[str, Any]:
    for i in range(start, end):
        micro_time = int(time.time() * 1_000_000)
        yield f"insert into table (id, a, b, t) values ({i}, 1, 2, {micro_time});\n"

async def main() -> None:
    print('Gen ...')

    # str_io = StringIO()
    # for i in range(0, MAX_ROW, CHUNK_ROW):
    #     print(f"Sending {i}..{i + CHUNK_ROW}")
    #
    #     async for task in create_insert_statements(i, i + CHUNK_ROW):
    #         str_io.write(task)
    #
    # with open('./insert3.txt', 'w+') as f:
    #     str_io.seek(0)
    #     shutil.copyfileobj(str_io, f)

    with open('./insert3.txt', 'w+') as f:
        for i in range(0, MAX_ROW, CHUNK_ROW):
            print(f"Sending {i}..{i + CHUNK_ROW}")

            async for task in create_insert_statements(i, i + CHUNK_ROW):
                f.write(task)

if __name__ == "__main__":
    asyncio.run(main())
