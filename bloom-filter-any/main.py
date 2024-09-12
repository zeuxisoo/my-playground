#!/usr/bin/env python

from typing import Self, Optional, Type
from hashlib import sha1
from math import log

class BloomFilter:
    def __init__(self: Self, size: int, number_hashes: int, salt: Optional[str] = None) -> None:
        self.size = size
        self.number_hashes = number_hashes
        self.salt = "" if salt is None else salt
        self.bit_array = [0] * size

    def add(self: Self, element: str) -> None:
        for i in range(self.number_hashes):
            digest = sha1(f"{self.salt}{element}{i}".encode("utf-8")).hexdigest()
            index = int(digest, 16) % self.size

            self.bit_array[index] = 1

    def lookup(self: Self, element: str) -> bool:
        for i in range(self.number_hashes):
            digest = sha1(f"{self.salt}{element}{i}".encode("utf-8")).hexdigest()
            index = int(digest, 16) % self.size

            if self.bit_array[index] == 0:
                return False

        return True

    def estimate_dataset_size(self: Self) -> float:
        m = self.size
        k = self.number_hashes
        n = -(m / k) * log(1 - sum(self.bit_array) / m)

        return n

    def union(self: Self, other: Self) -> Self:
        if self.size != other.size or self.number_hashes != other.number_hashes:
            raise ValueError("Both filters must have the same size and hash count")

        result = BloomFilter(self.size, self.number_hashes)
        result.bit_array = [x | y for x, y in zip(self.bit_array, other.bit_array)]

        return result

    def intersection(self: Self, other: Self) -> Self:
        if self.size != other.size or self.number_hashes != other.number_hashes:
            raise ValueError("Both filters must have the same size and hash count")

        result = BloomFilter(self.size, self.number_hashes)
        result.bit_array = [x & y for x, y in zip(self.bit_array, other.bit_array)]

        return result

def main() -> None:
    coffees = [
        "Iced Coffee",
        "Iced Coffee with Milk",
        "Espresso",
        "Espresso Macchiato",
        "Flat White",
        "Latte Macchiato",
        "Cappuccino",
        "Mocha",
    ]

    bloom = BloomFilter(20, 2)
    for drink in coffees:
        bloom.add(drink)
        print(bloom.bit_array)

    print("---Experiment #1---")
    print(bloom.lookup("Flat White"))
    print(bloom.lookup("Americano"))
    print(bloom.estimate_dataset_size())

    #
    more_coffees = [
        "Iced Espresso",
        "Flat White",
        "Cappuccino",
        "Frappuccino",
        "Latte",
    ]

    bloom2 = BloomFilter(20, 2)
    for drink in more_coffees:
        bloom2.add(drink)

    bloom3 = bloom2.union(bloom)
    print("---Experiment #2---")
    print(bloom3.lookup("Mocha"))
    print(bloom3.lookup("Frappuccino"))
    print(bloom3.estimate_dataset_size())

    bloom4 = bloom2.intersection(bloom)
    print("---Experiment #3---")
    print(bloom4.lookup("Mocha"))
    print(bloom4.lookup("Flat White"))
    print(bloom4.estimate_dataset_size())

if __name__ == "__main__":
    main()
