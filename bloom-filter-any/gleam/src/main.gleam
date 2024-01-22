import gleam/io.{ println, debug }
import gleam/list

import bloomfilter

pub fn main() {
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

    let bloom = bloomfilter.new(20, 2, "")
    let bloom = list.fold(coffees, from: bloom, with: fn(acc, drink) {
        bloomfilter.add(acc, drink) |> fn(bf: bloomfilter.BloomFilter) {
            io.debug(bloomfilter.list_values(bf.bit_array))
            bf
        }
    })

    println("---Experiment #1---")
    debug(bloomfilter.lookup(bloom, "Flat White"))
    debug(bloomfilter.lookup(bloom, "Americano"))
    debug(bloomfilter.estimate_dataset_size(bloom))

    let more_coffees = [
        "Iced Espresso",
        "Flat White",
        "Cappuccino",
        "Frappuccino",
        "Latte",
    ]

    let bloom2 = bloomfilter.new(20, 2, "")
    let bloom2 = list.fold(more_coffees, from: bloom2, with: fn(acc, drink) {
        bloomfilter.add(acc, drink)
    })

    let bloom3 = bloomfilter.union(bloom2, bloom)
    println("---Experiment #2---")
    debug(bloomfilter.lookup(bloom3, "Mocha"))
    debug(bloomfilter.lookup(bloom3, "Frappuccino"))
    debug(bloomfilter.estimate_dataset_size(bloom3))

    let bloom4 = bloomfilter.intersection(bloom2, bloom)
    println("---Experiment #3---")
    debug(bloomfilter.lookup(bloom4, "Mocha"))
    debug(bloomfilter.lookup(bloom4, "Flat White"))
    debug(bloomfilter.estimate_dataset_size(bloom4))
}
