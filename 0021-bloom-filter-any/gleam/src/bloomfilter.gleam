import gleam/result.{unwrap}
import gleam/int
import gleam/string
import gleam/iterator as iter
import gleam/bit_array
import gleam/list
import gleam/float
// import gleam/io.{debug}

// external
// - type for atom
type HashAlgorithm {
    Sha
}

@external(erlang, "crypto", "hash")
fn hash(a: HashAlgorithm, b: BitArray) -> BitArray

@external(erlang, "math", "log")
fn log(a: Float) -> Float

// bloom filter
pub type BloomFilter {
    BloomFilter(
        size: Int,
        number_hashes: Int,
        salt: String,
        bit_array: List(#(Int, Int)), // support update index value not List(Int)
    )
}

pub fn new(size: Int, number_hashes: Int, salt: String) -> BloomFilter {
    BloomFilter(
        size,
        number_hashes,
        salt,
        bit_array: list.map(list.range(0, size - 1), fn(item) {
            #(item, 0)
        })
        // bit_array: iter.to_list(iter.zip(
        //     iter.range(0, size),
        //     iter.take(iter.repeat(0), size),
        // )),
    )
}

pub fn add(bf: BloomFilter, element: String) -> BloomFilter {
    let hash_range = iter.range(0, bf.number_hashes - 1) |> iter.to_list()

    let new_bit_array =list.fold(hash_range, bf.bit_array, fn(acc, i) {
        let digest = bit_array.base16_encode(hash(
            Sha, // type cast to :sha
            [bf.salt, element, int.to_string(i)] |> string.concat |> bit_array.from_string(),
        ))

        let index = unwrap(int.base_parse(digest, 16), 0) % bf.size
        // let index = case int.base_parse(digest, 16) {
        //     Ok(index) -> index
        //     Error(Nil) -> 0
        // } % bf.size

        let bit_array = list.key_set(acc, index, 1) // update index

        bit_array
    })

    BloomFilter(bf.size, bf.number_hashes, bf.salt, new_bit_array)
}

pub fn lookup(bf: BloomFilter, element: String) -> Bool {
    list.fold_until(list.range(0, bf.number_hashes - 1), True, fn(acc, i) {
        let digest = bit_array.base16_encode(hash(
            Sha, // type cast to :sha
            [bf.salt, element, int.to_string(i)] |> string.concat |> bit_array.from_string(),
        ))

        let index = unwrap(int.base_parse(digest, 16), 0) % bf.size

        let status = case list.at(bf.bit_array, index) {
            Ok(#(_key, value)) -> {
                case value {
                    _ if value == 0 -> list.Stop(False)
                    _ -> list.Continue(acc)
                }
            }
            Error(Nil) -> list.Stop(acc)
        }

        status
    })
}

pub fn estimate_dataset_size(bf: BloomFilter) -> Float {
    let m = int.to_float(bf.size)
    let k = int.to_float(bf.number_hashes)
    let n = float.negate(m /. k) *. log(int.to_float(1) -. int.to_float(int.sum(list_values(bf.bit_array))) /. m)

    n
}

pub fn union(target: BloomFilter, other: BloomFilter) -> BloomFilter {
    let result = case True {
        _ if target.size != other.size && target.number_hashes != other.number_hashes -> {
            panic as "Both filters must have the same size and hash count"
        }
        _ -> {
            let bit_array = list.index_map(
                list.zip(
                    list_values(target.bit_array),
                    list_values(other.bit_array),
                ),
                fn(item, i) {
                    let #(x, y) = item

                    #(i, int.bitwise_or(x, y))
                }
            )

            BloomFilter(
                target.size,
                target.number_hashes,
                target.salt,
                bit_array
            )
        }
    }

    result
}

pub fn intersection(target: BloomFilter, other: BloomFilter) -> BloomFilter {
    let result = case True {
        _ if target.size != other.size && target.number_hashes != other.number_hashes -> {
            panic as "Both filters must have the same size and hash count"
        }
        _ -> {
            let bit_array = list.index_map(
                list.zip(
                    list_values(target.bit_array),
                    list_values(other.bit_array),
                ),
                fn(item, i) {
                    let #(x, y) = item

                    #(i, int.bitwise_and(x, y))
                }
            )

            BloomFilter(
                target.size,
                target.number_hashes,
                target.salt,
                bit_array
            )
        }
    }

    result
}

// helpers
pub fn list_values(input: List(#(a, b))) -> List(b) {
    list.map(input, fn(item) {
        // let #(_, value) = item
        // value
        item.1
    })
}
