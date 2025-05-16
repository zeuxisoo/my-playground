#!/usr/bin/env python

import sys
import time
import struct
import binascii
# import dis
# import marshal
from typing import Final, IO, Union, List

FLAG_REF: Final = "\x80"

def read_pyc() -> None:
    file = open("__pycache__/dummy.cpython-310.pyc", "rb")

    magic     = file.read(4)
    magic_no  = struct.unpack("<H", magic[0:2])[0]
    magic_hex = binascii.hexlify(magic).decode('utf-8')

    bit_field = file.read(4)
    bit_field = int.from_bytes(bit_field, byteorder=sys.byteorder)

    timestamp = file.read(4)
    timestamp = time.strftime(
        "%Y-%m-%d %H:%M:%S",
        time.localtime(struct.unpack('I', timestamp)[0])
    )

    size = file.read(4)
    size = struct.unpack('I', size)[0]

    print(
        "Magic: (No: {}, Hex: {}), BitField: {}, Timestamp: {}, Size: {}".format(
            magic_no, magic_hex, bit_field, timestamp, size,
        )
    )

    print_line()

    # References
    #
    # PyMarshal_ReadObjectFromFile -> read_object -> r_object
    # - https://github.com/python/cpython/blob/3.10/Python/marshal.c#L1302
    #
    # Show the opcodes of the code object
    # - dis.disassemble(marshal.load(file))
    #
    read_object(file)

    file.close()

def read_object(file: IO) -> Union[int, str, List, None]:
    code = file.read(1)

    flag = ord(code) & ord(FLAG_REF)
    type = ord(code) & ~ord(FLAG_REF)

    print("Code: {:9s}, Flag: {:5d}, Type: {:5d}, TypeChar: {}".format(str(code), flag, type, chr(type)))

    match chr(type):
        case "c": # TYPE_CODE
            arg_count          = read_long(file)
            pos_only_arg_count = read_long(file)
            kw_only_arg_count  = read_long(file)
            n_locals           = read_long(file)
            stack_size         = read_long(file)
            flags              = read_long(file)
            code               = read_object(file)
            consts             = read_object(file)
            names              = read_object(file)
            var_names          = read_object(file)
            free_vars          = read_object(file)
            cell_vars          = read_object(file)
            filename           = read_object(file)
            name               = read_object(file)
            first_line_no      = read_long(file)
            lno_tab            = read_object(file)

            print_line()
            print_key_value("ArgCount", arg_count)
            print_key_value("PosOnlyArgCount", pos_only_arg_count)
            print_key_value("KwOnlyArgCount", kw_only_arg_count)
            print_key_value("NLocals", n_locals)
            print_key_value("StackSize", stack_size)
            print_key_value("Flags", flags)
            print_key_value("Code", code)
            print_key_value("Consts", consts)
            print_key_value("Names", names)
            print_key_value("VarNames", var_names)
            print_key_value("FreeVars", free_vars)
            print_key_value("CellVars", cell_vars)
            print_key_value("Filename", filename)
            print_key_value("Name", name)
            print_key_value("FirstLineNo", first_line_no)
            print_key_value("LnoTab", lno_tab)

        case "s": # TYPE_STRING
            size = read_long(file)

            return file.read(size)
        case ")": # TYPE_SMALL_TUPLE
            length = ord(file.read(1))
            data = []

            for i in range(length):
                data.append(read_object(file))

            return data
        case "z": # TYPE_SHORT_ASCII
            size = ord(file.read(1))

            return file.read(size)
        case "Z": # TYPE_SHORT_ASCII_INTERNED
            size = ord(file.read(1))

            return file.read(size)
        case "r": # TYPE_REF
            size = read_long(file)

            # Free reference, nothing to do

            return size
        case "N": # TYPE_NONE
            # Nothing to do
            return None
        case _:
            print("!! Unknown code: {}".format(code))

def read_long(file: IO) -> int:
    bytes = file.read(4)

    return struct.unpack('<L', bytes)[0]

def print_line() -> None:
    print("-" * 10)

def print_key_value(key: str, value: Union[str, List]) -> None:
    print("=> {:16s}: {}".format(key, value))

if __name__ == "__main__":
    read_pyc()
