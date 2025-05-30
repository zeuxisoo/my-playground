using SHA

mutable struct BloomFilter
    size::Int
    number_hashes::Int
    salt::AbstractString
    bit_array::Array{Int, 1}

    function BloomFilter(size::Int, number_hashes::Int, salt::AbstractString="")
        new(size, number_hashes, salt, zeros(Int, size))
    end
end

function add!(bf::BloomFilter, element::AbstractString)::Nothing
    for i in 0:bf.number_hashes-1
        digest = bytes2hex(sha1(string(bf.salt, element, i)))
        index = parse(BigInt, digest, base=16) % bf.size

        bf.bit_array[index + 1] = 1 # array index start from 1 not 0
    end
end

function lookup(bf::BloomFilter, element::AbstractString)::Bool
    for i in 0:bf.number_hashes-1
        digest = bytes2hex(sha1(string(bf.salt, element, i)))
        index = parse(BigInt, digest, base=16) % bf.size

        if checkbounds(Bool, bf.bit_array, index + 1) && bf.bit_array[index + 1] == 0
            return false
        end
    end

    return true
end

function estimate_dataset_size(bf::BloomFilter)::AbstractFloat
    m = bf.size
    k = bf.number_hashes
    n = -(m / k) * log(1 - sum(bf.bit_array) / m)

    return n
end

function union(bf::BloomFilter, other::BloomFilter)::BloomFilter
    if bf.size != other.size || bf.number_hashes != other.number_hashes
        error("Both filters must have the same size and hash count")
    end

    result = BloomFilter(bf.size, bf.number_hashes)
    result.bit_array = [x | y for (x, y) in zip(bf.bit_array, other.bit_array)]

    # new_bit_array = Int[]
    # for (x, y) in zip(bf.bit_array, other.bit_array)
    #     push!(new_bit_array, x | y)
    # end
    # result.bit_array = new_bit_array

    return result
end

function intersection(bf::BloomFilter, other::BloomFilter)::BloomFilter
    if bf.size != other.size || bf.number_hashes != other.number_hashes
        error("Both filters must have the same size and hash count")
    end

    result = BloomFilter(bf.size, bf.number_hashes)
    result.bit_array = [x & y for (x, y) in zip(bf.bit_array, other.bit_array)]

    return result
end

function main()
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
    for drink in coffees
        add!(bloom, drink)
        println(bloom.bit_array)
    end

    println("---Experiment #1---")
    println(lookup(bloom, "Flat White"))
    println(lookup(bloom, "Americano"))
    println(estimate_dataset_size(bloom))

    #
    more_coffees = [
        "Iced Espresso",
        "Flat White",
        "Cappuccino",
        "Frappuccino",
        "Latte",
    ]

    bloom2 = BloomFilter(20, 2)
    for drink in more_coffees
        add!(bloom2, drink)
    end

    bloom3 = union(bloom2, bloom)
    println("---Experiment #2---")
    println(lookup(bloom3, "Mocha"))
    println(lookup(bloom3, "Frappuccino"))
    println(estimate_dataset_size(bloom3))

    bloom4 = intersection(bloom2, bloom)
    println("---Experiment #3---")
    println(lookup(bloom4, "Mocha"))
    println(lookup(bloom4, "Flat White"))
    println(estimate_dataset_size(bloom4))
end

main()
