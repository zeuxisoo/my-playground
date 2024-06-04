<?php
// Load the V shared library
$lib = FFI::cdef(<<<'EOD'
    int square(int i);
    double sqrt_of_sum_of_squares(double x, double y);

    typedef struct {
        const char* str; // immutable string, mutable ptr
        int len;
    } vstring;

    vstring process_v_string(vstring s);
EOD, "./test.dylib");

// Pass an integer to a V function, and receiving back an integer
echo "lib->square(10) result is {$lib->square(10)}\n";
assert($lib->square(10) === 100, "Cannot validate V square().");

// Pass a floating point number to a V function
assert($lib->sqrt_of_sum_of_squares(1.1, 2.2) === sqrt(1.1*1.1 + 2.2*2.2), "Cannot validate V sqrt_of_sum_of_squares().");

// Passing a V string to a V function, and receiving back a V string
/*
$word = 'World';
$size  = mb_strlen($word);

$v_word = $lib->new("char[$size]", owned: false);
FFI::memcpy($v_word, $word, $size);
register_shutdown_function(function() use ($v_word) {
    FFI::free($v_word);
});

$vstring = $lib->new("vstring");
$vstring->str = $v_word;
$vstring->len = 5;
*/
$word = 'World';
$size  = mb_strlen($word);

$vstring = $lib->new("vstring");
$vstring->str = $lib->new("char[$size]", owned: false);
$vstring->len = 5;

FFI::memcpy($vstring->str, $word, $size);

assert($lib->process_v_string($vstring)->str, "v World v");
echo 'Hello ', $lib->process_v_string($vstring)->str;
