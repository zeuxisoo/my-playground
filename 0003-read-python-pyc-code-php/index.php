<?php
define('FLAG_REF', "\x80");

function readPyc() {
    $fp = fopen("__pycache__/dummy.cpython-310.pyc", "rb+");

    // Magic number equal to python version
    // - https://github.com/python/cpython/blob/main/Lib/importlib/_bootstrap_external.py#L232=
    // - https://github.com/google/pytype/blob/main/pytype/pyc/magic.py#L6=
    $magic    = fread($fp, 4);
    $magicNo  = unpack("v", substr($magic, 0, 2))[1];
    $magicHex = bin2hex($magic);

    $bitField = fread($fp, 4);
    $bitField = intval(bin2hex($bitField), 16); // unpack("L", $bitField)[1]

    $timestamp = fread($fp, 4);
    $timestamp = unpack("I", $timestamp)[1];
    $timestamp = gmdate("Y-m-d H:i:s", $timestamp + 8 * 3600);

    $size = fread($fp, 4);
    $size = unpack("I", $size)[1];

    printf(
        "Magic: (No: %d, Hex: %s), BitField: %d, Timestamp: %s, Size: %d\n",
        $magicNo,
        $magicHex,
        $bitField,
        $timestamp,
        $size,
    );

    printLine();

    readObject($fp);

    fclose($fp);
}

function readObject(mixed $fp): int|string|array|null {
    $code = fread($fp, 1);

    $flag = ord($code) & ord(FLAG_REF);
    $type = ord($code) & ~ord(FLAG_REF);

    printf(
        "Code: %-9s, Flag: %5d, Type: %5d, TypeChar: %s\n",
        sprintf("b'\x%s'", bin2hex($code)),
        $flag, $type, chr($type)
    );

    switch(chr($type)) {
        case "c": // TYPE_CODE
            $argCount        = readLong($fp);
            $posOnlyArgCount = readLong($fp);
            $kwOnlyArgCount  = readLong($fp);
            $nLocals         = readLong($fp);
            $stackSize       = readLong($fp);
            $flags           = readLong($fp);
            $code            = readObject($fp);
            $consts          = readObject($fp);
            $names           = readObject($fp);
            $varNames        = readObject($fp);
            $freeVars        = readObject($fp);
            $cellVars        = readObject($fp);
            $filename        = readObject($fp);
            $name            = readObject($fp);
            $firstLineNo     = readLong($fp);
            $lnoTab          = readObject($fp);

            printLine();
            printKeyValue("ArgCount", $argCount);
            printKeyValue("PosOnlyArgCount", $posOnlyArgCount);
            printKeyValue("KwOnlyArgCount", $kwOnlyArgCount);
            printKeyValue("NLocals", $nLocals);
            printKeyValue("StackSize", $stackSize);
            printKeyValue("Flags", $flags);
            printKeyValue("Code", convertBytes($code));
            printKeyValue("Consts", $consts);
            printKeyValue("Names", $names);
            printKeyValue("VarNames", $varNames);
            printKeyValue("FreeVars", $freeVars);
            printKeyValue("CellVars", $cellVars);
            printKeyValue("Filename", $filename);
            printKeyValue("Name", $name);
            printKeyValue("FirstLineNo", $firstLineNo);
            printKeyValue("LnoTab", convertBytes($lnoTab));
            break;
        case "s": # TYPE_STRING
            $size = readLong($fp);

            return fread($fp, $size);
            break;
        case ")": # TYPE_SMALL_TUPLE
            $length = ord(fread($fp, 1));
            $data   = [];

            for($i=0; $i<$length; $i++) {
                $data[] = readObject($fp) ?? "None";
            }

            return $data;
            break;
        case "z": # TYPE_SHORT_ASCII
            $size = ord(fread($fp, 1));

            return fread($fp, $size);
            break;
        case "Z": # TYPE_SHORT_ASCII_INTERNED
            $size = ord(fread($fp, 1));

            return fread($fp, $size);
            break;
        case "r": # TYPE_REF
            $size = readLong($fp);

            # Free reference, nothing to do

            return $size;
            break;
        case "N": # TYPE_NONE
            # Nothing to do
            return null;
        default:
            printf("!! Unknown code: %s\n", sprintf("b'\x%s'", bin2hex($code)));
            break;
    }

    return null;
}

function readLong(mixed $fp): int {
    $bytes = fread($fp, 4);

    return unpack("V", $bytes)[1];
}

function printLine(): void {
    echo str_repeat("-", 10),"\n";
}

function printKeyValue(string $key, string|array $value): void {
    if (is_array($value)) {
        $value = "[".implode(", ", $value)."]";
    }

    printf("=> %-16s: %s\n", $key, $value);
}

function convertBytes(string $code): string {
    $items = [];

    // Same as but want array and readable in hex array
    // print_r(unpack("C*", $code)); # dec array
    // print_r(unpack("H*", $code)); # hex string
    for($i=0; $i<strlen($code); $i++) {
        $items[] = "\x".bin2hex($code[$i]);
    }

    return '"'.implode("", $items).'"';
}

readPyc();
