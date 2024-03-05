#!/usr/bin/env ruby

require 'pp'
require 'digest'

class BloomFilter
    attr_reader :size
    attr_reader :number_hashes
    attr_reader :salt
    attr_accessor :bit_array

    def initialize(size, number_hashes, salt="")
        @size          = size
        @number_hashes = number_hashes
        @salt          = salt
        @bit_array     = Array.new(size, 0)
    end

    def add(element)
        self.number_hashes.times { |i|
            digest = Digest::SHA1.hexdigest("#{@salt}#{element}#{i}")
            index = digest.to_i(16) % @size

            @bit_array[index] = 1
        }
    end

    def lookup(element)
        self.number_hashes.times { |i|
            digest = Digest::SHA1.hexdigest("#{@salt}#{element}#{i}")
            index = digest.to_i(16) % @size

            return false if !@bit_array[index].nil? && @bit_array[index] == 0
        }

        true
    end

    def estimate_dataset_size()
        m = @size
        k = @number_hashes
        n = -(m / k) * Math::log(1 - @bit_array.sum / m.to_f) # .to_f for make division return float

        n
    end

    def union(other)
        if @size != other.size || @number_hashes != other.number_hashes then
            raise "Both filters must have the same size and hash count"
        end

        result = BloomFilter.new(@size, @number_hashes)
        result.bit_array = @bit_array.zip(other.bit_array).map { |x, y| x | y } # map syntax not cover in doc but work

        result
    end

    def intersection(other)
        if @size != other.size || @number_hashes != other.number_hashes then
            raise "Both filters must have the same size and hash count"
        end

        result = BloomFilter.new(@size, @number_hashes)
        result.bit_array = @bit_array.zip(other.bit_array).map { |x, y| x & y } # map syntax not cover in doc but work

        result
    end

end

def dump(value)
    case value
    in Array | String | Float
        puts "#{value}\n"
    in TrueClass | FalseClass
        puts sprintf("%s\n", value ? "true" : "false")
    else
        puts "unknown: #{value}\n"
    end
end

if __FILE__ == $0
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
    coffees.each { |drink|
        bloom.add(drink)
        dump(bloom.bit_array)
    }

    dump("---Experiment #1---")
    dump(bloom.lookup("Flat White"))
    dump(bloom.lookup("Americano"))
    dump(bloom.estimate_dataset_size())

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
    dump("---Experiment #2---")
    dump(bloom3.lookup("Mocha"))
    dump(bloom3.lookup("Frappuccino"))
    dump(bloom3.estimate_dataset_size())

    bloom4 = bloom2.intersection(bloom)
    dump("---Experiment #3---")
    dump(bloom4.lookup("Mocha"))
    dump(bloom4.lookup("Flat White"))
    dump(bloom4.estimate_dataset_size())
end
