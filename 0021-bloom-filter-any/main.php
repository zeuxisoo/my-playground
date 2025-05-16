<?php
class BloomFilter {

    public $bit_array = [];

    public function __construct(
        public int $size,
        public int $number_hashes,
        protected string $salt
    ) {
        $this->bit_array = array_fill(0, $size, 0);
    }

    public function add(string $element): void {
        for($i=0; $i<$this->number_hashes; $i++) {
            $digest = hash('sha1', "{$this->salt}{$element}{$i}");
            $index  = gmp_intval(gmp_mod(gmp_strval(gmp_init($digest, 16), 10), $this->size)); // arbitrary precision

            $this->bit_array[$index] = 1;
        }
    }

    public function lookup(string $element): bool {
        for($i=0; $i<$this->number_hashes; $i++) {
            $digest = hash('sha1', "{$this->salt}{$element}{$i}");
            $index  = gmp_intval(gmp_mod(gmp_strval(gmp_init($digest, 16), 10), $this->size)); // arbitrary precision

            if (array_key_exists($index, $this->bit_array) && $this->bit_array[$index] === 0) {
                return false;
            }
        }

        return true;
    }

    public function estimate_dataset_size(int $precision = 15): string {
        $m = $this->size;
        $k = $this->number_hashes;
        $n = -($m / $k) * log(1 - array_sum($this->bit_array) / $m);

        return number_format(number_format($n, 16), $precision); // precision, float type only show 14 length
    }

    public function union(BloomFilter $other): BloomFilter {
        if ($this->size !== $other->size || $this->number_hashes !== $other->number_hashes) {
            throw new Exception('Both filters must have the same size and hash count');
        }

        $result = new BloomFilter($this->size, $this->number_hashes, '');
        $result->bit_array = array_map(
            fn($bits) => $bits[0] | $bits[1],
            zip($this->bit_array, $other->bit_array)
        );

        return $result;
    }

    public function intersection(BloomFilter $other): BloomFilter {
        if ($this->size !== $other->size || $this->number_hashes !== $other->number_hashes) {
            throw new Exception('Both filters must have the same size and hash count');
        }

        $result = new BloomFilter($this->size, $this->number_hashes, '');
        $result->bit_array = array_map(
            fn($bits) => $bits[0] & $bits[1],
            zip($this->bit_array, $other->bit_array)
        );

        return $result;
    }

}

function zip(array $items1, array $items2): array {
    $new_items = [];

    foreach($items1 as $i => $item) {
        $new_items[] = [$item, $items2[$i]];
    }

    return $new_items;
}

//
(new class {
    public function __invoke(): void {
        $coffees = [
            "Iced Coffee",
            "Iced Coffee with Milk",
            "Espresso",
            "Espresso Macchiato",
            "Flat White",
            "Latte Macchiato",
            "Cappuccino",
            "Mocha",
        ];

        $bloom = new BloomFilter(20, 2, '');
        foreach($coffees as $drink) {
            $bloom->add($drink);

            $this->dump($bloom->bit_array);
        }

        $this->dump("---Experiment #1---");
        $this->dump($bloom->lookup("Flat White"));
        $this->dump($bloom->lookup("Americano"));
        $this->dump($bloom->estimate_dataset_size());

        //
        $more_coffees = [
            'Iced Espresso',
            'Flat White',
            'Cappuccino',
            'Frappuccino',
            'Latte',
        ];

        $bloom2 = new BloomFilter(20, 2, '');
        foreach($more_coffees as $drink) {
            $bloom2->add($drink);
        }

        $bloom3 = $bloom2->union($bloom);
        $this->dump('---Experiment #2---');
        $this->dump($bloom3->lookup('Mocha'));
        $this->dump($bloom3->lookup('Frappuccino'));
        $this->dump($bloom3->estimate_dataset_size());

        $bloom4 = $bloom2->intersection($bloom);
        $this->dump('---Experiment #3---');
        $this->dump($bloom4->lookup('Mocha'));
        $this->dump($bloom4->lookup('Flat White'));
        $this->dump($bloom4->estimate_dataset_size(precision: 16));
    }

    private function dump(array|string|bool $value): void {
        echo match(gettype($value)) {
            "string"  => $value,
            "boolean" => $value ? "true" : "false",
            "array"   => "[".implode(', ', $value)."]",
        },"\n";
    }
})();
