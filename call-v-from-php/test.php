<?php
$lib = FFI::cdef(<<<'EOD'
    int square(int i);
    double sqrt_of_sum_of_squares(double x, double y);
EOD, "./test.dylib");

echo "lib->square(10) result is {$lib->square(10)}\n";
assert($lib->square(10) === 100, "Cannot validate V square().");

assert($lib->sqrt_of_sum_of_squares(1.1, 2.2) === sqrt(1.1*1.1 + 2.2*2.2), "Cannot validate V sqrt_of_sum_of_squares().");
