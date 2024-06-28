from checksums/sha1 import securehash, `$`
from std/strformat import fmt
from std/strutils import toLowerAscii, join, `%`, formatFloat, FloatFormatMode
from std/options import get
from std/math import log, E
from std/sequtils import foldl, zip, mapIt, map
from bigints import BigInt, initBigInt, toInt, `+=`, `*=`, `*`, `mod`

{.push warning[CastSizes]: off.}

proc dump[T: seq[int]|string|bool|float](value: T): void =
    if value is bool:
        echo value
    elif value is seq[int]:
        # need casting
        # echo "[" & join(value, ", ") & "]"
        # echo fmt"""[{join(value, ", ")}]"""
        # echo "[$1]" % [value.join(", ")]
        echo "[$1]" % [join(cast[seq[int]](value), ", ")]
    elif value is string:
        echo $value
    elif value is float:
        echo value
    else:
        echo "unknown"

proc parseBigInt(hex: string): BigInt =
    var decimal = initBigInt(0)
    var base = initBigInt(1)

    for i in countdown(hex.high, 0):
        if hex[i] >= '0' and hex[i] <= '9':
            decimal += initBigInt(ord(hex[i]) - 48) * base
            base *= initBigInt(16)
        elif hex[i] >= 'A' and hex[i] <= 'F':
            decimal += initBigInt(ord(hex[i]) - 55) * base
            base *= initBigInt(16)
        elif hex[i] >= 'a' and hex[i] <= 'f':
            decimal += initBigInt(ord(hex[i]) - 87) * base
            base *= initBigInt(16)

    return decimal

type BloomFilter = object
    size: int
    numberHashes: int
    salt: string
    bitArray: seq[int]

proc newBloomFilter(size: int, numberHashes: int, salt: string = ""): BloomFilter =
    # BloomFilter(
    #     size: size,
    #     numberHashes: numberHashes,
    #     salt: salt,
    #     bitArray: newSeq[int](size)
    # )
    # result keyword is special variable for return
    result.size = size
    result.numberHashes = numberHashes
    result.salt = salt
    result.bitArray = newSeq[int](size)

proc add(self: var BloomFilter, element: string) =
    for i in 0..<self.numberHashes:
        #[
            let digest = $fmt"{self.salt}{element}{i}".secureHash
            let index  = parseBigInt(digest) mod self.size.initBigInt

            self.bitArray[index.toInt[:int].get()] = 1
        ]#
        let hash   = secureHash(fmt"{self.salt}{element}{i}")
        let digest = toLowerAscii($hash)
        let index  = parseBigInt(digest) mod initBigInt(self.size)

        self.bitArray[get(toInt[int](index))] = 1

proc lookup(self: BloomFilter, element: string): bool =
    for i in 0..<self.numberHashes:
        let hash   = secureHash(fmt"{self.salt}{element}{i}")
        let digest = toLowerAscii($hash)
        let index  = parseBigInt(digest) mod initBigInt(self.size)

        if self.bitArray[get(toInt[int](index))] == 0:
            return false

    return true

proc estimateDatasetSize(self: BloomFilter, precision: int = 15): string =
    let m = self.size
    let k = self.numberHashes
    # let n = -(m / k) * log(1 - self.bitArray.foldl(a + b) / m, E)
    let n = -(m / k) * log(1 - foldl(self.bitArray, a + b) / m, E)

    # return n.formatFloat(FloatFormatMode.ffDecimal, precision)
    return formatFloat(n, FloatFormatMode.ffDecimal, precision)

proc union(self: BloomFilter, other: BloomFilter): BloomFilter =
    if self.size != other.size or self.numberHashes != other.numberHashes:
        raise newException(ValueError, "Both filters must have the same size and hash count")

    var bloom = newBloomFilter(self.size, self.numberHashes)
    #[
        # from std/sugar import `=>`
        # from std/sequtils import map
        bloom.bitArray = map(zip(self.bitArray, other.bitArray), x => x[0] or x[1])

        # from std/sequtils import map
        bloom.bitArray = map(zip(self.bitArray, other.bitArray), proc(x: tuple): int = x[0] or x[1])

        bloom.bitArray = zip(self.bitArray, other.bitArray).map do (x: tuple) -> int: x[0] or x[1]
        bloom.bitArray = map(zip(self.bitArray, other.bitArray)) do (x: tuple) -> int: x[0] or x[1]
    ]#
    # proc callback(x: tuple): string = x[0] & x[1]
    bloom.bitArray = mapIt(zip(self.bitArray, other.bitArray), it[0] or it[1])

    return bloom

proc intersection(self: BloomFilter, other: BloomFilter): BloomFilter =
    if self.size != other.size or self.numberHashes != other.numberHashes:
        raise newException(ValueError, "Both filters must have the same size and hash count")

    var bloom = newBloomFilter(self.size, self.numberHashes)
    bloom.bitArray = mapIt(zip(self.bitArray, other.bitArray), it[0] and it[1])

    return bloom

#
when isMainModule:
    let coffees = [
        "Iced Coffee",
        "Iced Coffee with Milk",
        "Espresso",
        "Espresso Macchiato",
        "Flat White",
        "Latte Macchiato",
        "Cappuccino",
        "Mocha",
    ]

    var bloom = newBloomFilter(20, 2)
    for drink in coffees:
        bloom.add(drink)
        dump(bloom.bitArray)

    dump("---Experiment #1---")
    dump(bloom.lookup("Flat White"))
    dump(bloom.lookup("Americano"))
    dump(bloom.estimateDatasetSize())

    #
    let more_coffees = [
        "Iced Espresso",
        "Flat White",
        "Cappuccino",
        "Frappuccino",
        "Latte",
    ]

    var bloom2 = newBloomFilter(20, 2)
    for drink in more_coffees:
        bloom2.add(drink)

    var bloom3 = bloom2.union(bloom)
    dump("---Experiment #2---")
    dump(bloom3.lookup("Mocha"))
    dump(bloom3.lookup("Frappuccino"))
    dump(bloom3.estimateDatasetSize(15))

    var bloom4 = bloom2.intersection(bloom)
    dump("---Experiment #3---")
    dump(bloom4.lookup("Mocha"))
    dump(bloom4.lookup("Flat White"))
    dump(bloom4.estimateDatasetSize(16))
