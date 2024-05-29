defmodule BloomFilter do

    import Bitwise, only: [|||: 2]

    @type t :: %__MODULE__{
        size: integer,
        number_hashes: integer,
        salt: String.t,
        bit_array: [integer]
    }

    @enforce_keys [:size, :number_hashes, :salt, :bit_array]
    defstruct [:size, :number_hashes, :salt, :bit_array]

    @spec new(integer, integer, String.t) :: t
    def new(size, number_hashes, salt \\ "") do
        new(size, number_hashes, salt, List.duplicate(0, size))
    end

    @spec new(integer, integer, String.t, [integer]) :: t
    def new(size, number_hashes, salt, bit_array) do
        %BloomFilter{
            size: size,
            number_hashes: number_hashes,
            salt: salt,
            bit_array: bit_array
        }
    end

    @spec add(t, String.t) :: t
    def add(bloom, element) do
        # new_bit_array = bloom.bit_array
        # new_bit_array = Enum.reduce(0..bloom.number_hashes-1, new_bit_array, fn i, acc ->
        #     digest = :crypto.bytes_to_integer(:crypto.hash(:sha, "#{bloom.salt}#{element}#{i}"))
        #     index  = rem(digest, bloom.size)
        #     List.replace_at(acc, index, 1)
        # end)
        #
        # %{bloom | bit_array: new_bit_array}
        new_bit_array = for i <- 0..bloom.number_hashes - 1, reduce: bloom.bit_array do
            acc ->
                digest = :crypto.hash(:sha, "#{bloom.salt}#{element}#{i}") |> Base.encode16(case: :lower)
                index  = Integer.parse(digest, 16) |> elem(0) |> rem(bloom.size)

                List.replace_at(acc, index, 1)
        end

        %{bloom | bit_array: new_bit_array}
    end

    @spec lookup(t, String.t) :: boolean
    def lookup(bloom, element) do
        lookup(bloom, element, 0)
    end

    @spec lookup(t, String.t, integer) :: boolean
    # defp lookup(bloom, element, i) do
    #     if i >= bloom.number_hashes - 1 do
    #         true
    #     else
    #         digest = :crypto.hash(:sha, bloom.salt <> element <> to_string(i)) |> Base.encode16(case: :lower)
    #         index  = Integer.parse(digest, 16) |> elem(0) |> rem(bloom.size)
    #
    #         if Enum.at(bloom.bit_array, index) == 0 do
    #             false
    #         else
    #             lookup(bloom, element, i + 1)
    #         end
    #     end
    # end
    defp lookup(bloom, _element, i) when i >= bloom.number_hashes - 1, do: true
    defp lookup(bloom, element, i) do
        digest = :crypto.hash(:sha, "#{bloom.salt}#{element}#{i}") |> Base.encode16(case: :lower)
        index  = Integer.parse(digest, 16) |> elem(0) |> rem(bloom.size)

        if Enum.at(bloom.bit_array, index) === 0 do
            false
        else
            lookup(bloom, element, i + 1)
        end
    end

    @spec estimate_dataset_size(t) :: float
    def estimate_dataset_size(bloom) do
        m = bloom.size
        k = bloom.number_hashes
        n = -(m / k) * :math.log(1 - Enum.sum(bloom.bit_array) / m)

        n
    end

    @spec union(t, t) :: t
    def union(target, other) do
        if target.size !== other.size and target.number_hashes !== other.number_hashes do
            raise("Both filters must have the same size and hash count")
        end

        result = new(target.size, target.number_hashes)

        # new_bit_array = Enum.map(
        #     Enum.zip(target.bit_array, other.bit_array),
        #     fn {x, y} ->
        #         x ||| y
        #     end
        # )
        #
        # new_bit_array = Enum.zip(target.bit_array, other.bit_array) |> Enum.map(fn item ->
        #     elem(item, 0) ||| elem(item, 1)
        # end)
        #
        # new_bit_array = Stream.zip_with([target.bit_array, other.bit_array], fn [x, y] ->
        #     x ||| y
        # end) |> Enum.to_list()
        #
        # new_bit_array = Stream.zip_with(target.bit_array, other.bit_array, fn x, y ->
        #     x ||| y
        # end) |> Enum.to_list()
        #
        # new_bit_array = Enum.zip_with([target.bit_array, other.bit_array], fn [x, y] ->
        #     x ||| y
        # end)
        #
        new_bit_array = Enum.zip_with(target.bit_array, other.bit_array, fn x, y -> x ||| y end)

        %{result | bit_array: new_bit_array}
    end

    @spec intersection(t, t) :: t
    def intersection(target, other) do
        if target.size !== other.size and target.number_hashes !== other.number_hashes do
            raise("Both filters must have the same size and hash count")
        end

        result = new(target.size, target.number_hashes)
        new_bit_array = Enum.zip_with(target.bit_array, other.bit_array, fn x, y -> Bitwise.band(x, y) end)

        %{result | bit_array: new_bit_array}
    end

end

defmodule Main do

    def main do
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
        bloom = for drink <- coffees, reduce: bloom do
            acc ->
                BloomFilter.add(acc, drink) |> fn acc ->
                    IO.inspect(acc.bit_array)
                    acc
                end.()
        end

        IO.puts("---Experiment #1---")
        IO.puts(BloomFilter.lookup(bloom, "Flat White"))
        IO.puts(BloomFilter.lookup(bloom, "Americano"))
        IO.puts(BloomFilter.estimate_dataset_size(bloom))

        #
        more_coffees = [
            "Iced Espresso",
            "Flat White",
            "Cappuccino",
            "Frappuccino",
            "Latte",
        ]

        bloom2 = BloomFilter.new(20, 2)
        bloom2 = Enum.reduce(more_coffees, bloom2, fn drink, acc ->
            BloomFilter.add(acc, drink)
        end)

        bloom3 = BloomFilter.union(bloom2, bloom)
        IO.puts("---Experiment #2---")
        IO.puts(BloomFilter.lookup(bloom3, "Mocha"))
        IO.puts(BloomFilter.lookup(bloom3, "Frappuccino"))
        IO.puts(BloomFilter.estimate_dataset_size(bloom3))

        bloom4 = BloomFilter.intersection(bloom2, bloom)
        IO.puts("---Experiment #3---")
        IO.puts(BloomFilter.lookup(bloom4, "Mocha"))
        IO.puts(BloomFilter.lookup(bloom4, "Flat White"))
        IO.puts(BloomFilter.estimate_dataset_size(bloom4))
    end

end

Main.main
