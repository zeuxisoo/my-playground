require "digest/sha1"
require "big"
require "math"

class BloomFilter

    getter size : Int::Signed
    getter number_hashes : Int::Signed
    @salt : String                          # instance variable
    property bit_array : Array(Int::Signed)

    def initialize(size : Int::Signed, number_hashes : Int::Signed, salt : String = "")
        @size          = size
        @number_hashes = number_hashes
        @salt          = salt
        @bit_array     = Array(Int::Signed).new(size, 0)
    end

    def add(element : String) : Nil
        (0...@number_hashes).each do |i|
            digest = Digest::SHA1.hexdigest("#{@salt}#{element}#{i}")
            index  = digest.to_big_i(16) % 20

            @bit_array[index] = 1
        end
    end

    def lookup(element : String) : Bool
        @number_hashes.times.each do |i|
            digest = Digest::SHA1.hexdigest("#{@salt}#{element}#{i}")
            index  = digest.to_big_i(16) % 20

            return false if @bit_array[index] == 0
        end

        true
    end

    def estimate_dataset_size : Float
        m = @size
        k = @number_hashes
        n = -(m / k) * Math.log(1 - @bit_array.sum / m)

        n
    end

    def union(other : BloomFilter) : BloomFilter
        if @size != other.size || @number_hashes != other.number_hashes
            raise Exception.new("Both filters must have the same size and hash count")
        end

        result = BloomFilter.new(@size, @number_hashes)
        result.bit_array = @bit_array.zip(other.bit_array).map do |x, y|
            x | y
        end

        result
    end

    def intersection(other : BloomFilter) : BloomFilter
        if @size != other.size || @number_hashes != other.number_hashes
            raise Exception.new("Both filters must have the same size and hash count")
        end

        result = BloomFilter.new(@size, @number_hashes)
        result.bit_array = @bit_array.zip(other.bit_array).map { |x, y|
            x & y
        }

        result
    end

end

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

bloom = BloomFilter.new(20, 2)
coffees.each do |drink|
    bloom.add(drink)
    puts bloom.bit_array
end

puts "---Experiment #1---"
puts bloom.lookup("Flat White")
puts bloom.lookup("Americano")
puts bloom.estimate_dataset_size()

#
more_coffees = [
    "Iced Espresso",
    "Flat White",
    "Cappuccino",
    "Frappuccino",
    "Latte",
]

bloom2 = BloomFilter.new(20, 2)
more_coffees.each { |drink|
    bloom2.add(drink)
}

bloom3 = bloom2.union(bloom)
puts "---Experiment #2---"
puts bloom3.lookup("Mocha")
puts bloom3.lookup("Frappuccino")
puts bloom3.estimate_dataset_size()

bloom4 = bloom2.intersection(bloom)
puts "---Experiment #3---"
puts bloom4.lookup("Mocha")
puts bloom4.lookup("Flat White")
puts bloom4.estimate_dataset_size()
