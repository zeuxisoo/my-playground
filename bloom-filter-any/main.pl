#!/usr/bin/env perl

package BloomFilter;

use v5.36;
use strict;
use warnings;
use Data::Dumper;
use Digest::SHA qw(sha1_hex);
use Math::BigInt;
use Math::BigFloat;
use List::Util qw/sum/;
use builtin qw(true false is_bool);

# Disable warnings when using the builtin bool keyword
# ref: https://metacpan.org/pod/perldiag#Built-in-function-'%s'-is-experimental
no warnings 'experimental::builtin';

sub new ($class, $size, $number_hashes, $salt = '') {
    my $self = {
        size          => $size,
        number_hashes => $number_hashes,
        salt          => $salt,
        bit_array     => [(0) x $size],
    };

    bless $self, $class;
}

sub add ($self, $element) {
    for(my $i=0; $i<$self->{number_hashes}; $i++) {
        my $digest = sha1_hex($self->{salt}.$element.$i);
        my $index  = Math::BigInt->from_hex($digest) % $self->{size};

        $self->{bit_array}[$index] = 1;
    }
}

sub lookup ($self, $element) {
    for(my $i=0; $i<$self->{number_hashes}; $i++) {
        my $digest = sha1_hex($self->{salt}.$element.$i);
        my $index  = Math::BigInt->from_hex($digest) % $self->{size};

        if ($self->{bit_array}[$index] == 0) {
            return false;
        }
    }

    return true;
}

sub estimate_dataset_size ($self, $precision = 15) {
    my $m = $self->{size};
    my $k = $self->{number_hashes};
    my $n = -($m / $k) * log(1 - sum(@{$self->{bit_array}}) / $m);

    # Output do not equals other langauge precision
    #
    # use bignum ( p => -15 );
    # - or -
    # Math::BigFloat->precision(-15);
    # return Math::BigFloat->new($n);

    return Math::BigFloat->new(sprintf("%.".$precision."f", $n));
}

sub union ($self, $other) {
    if ($self->{size} != $other->{size} || $self->{number_hashes} != $other->{number_hashes}) {
        die "Both filters must have the same size and hash count";
    }

    my @new_bit_array;
    foreach my $bits (zip($self->{bit_array}, $other->{bit_array})) {
        my ($x, $y) = @$bits;

        push @new_bit_array, $x | $y;
    }

    my $result = BloomFilter->new($self->{size}, $self->{number_hashes});
    $result->{bit_array} = \@new_bit_array;

    return $result;
}

sub intersection ($self, $other) {
    if ($self->{size} != $other->{size} || $self->{number_hashes} != $other->{number_hashes}) {
        die "Both filters must have the same size and hash count";
    }

    my @new_bit_array;
    foreach my $bits (zip($self->{bit_array}, $other->{bit_array})) {
        my ($x, $y) = @$bits;

        push @new_bit_array, $x & $y;
    }

    my $result = BloomFilter->new($self->{size}, $self->{number_hashes});
    $result->{bit_array} = \@new_bit_array;

    return $result;
}

sub zip ($items1, $items2) {
    my @new_items;

    for my $i (0 .. $#{$items1}) {
        push @new_items, [$items1->[$i], $items2->[$i]];
    }

    return @new_items;
}


sub dump_with ($value) {
    if (ref($value) eq 'ARRAY') {
        printf("[%s]\n", join(", ", @{$value}));
    }elsif (is_bool($value)) {
        printf("%s\n", $value ? "true" : "false");
    }else{
        printf("%s\n", $value);
    }
}

sub main {
    my @coffees = (
        "Iced Coffee",
        "Iced Coffee with Milk",
        "Espresso",
        "Espresso Macchiato",
        "Flat White",
        "Latte Macchiato",
        "Cappuccino",
        "Mocha",
    );

    my $bloom = BloomFilter->new(20, 2);
    for my $drink (@coffees) {
        $bloom->add($drink);
        dump_with($bloom->{bit_array});
    }

    dump_with("---Experiment #1---");
    dump_with($bloom->lookup("Flat White"));
    dump_with($bloom->lookup("Americano"));
    dump_with($bloom->estimate_dataset_size());

    #
    my @more_coffees = (
		"Iced Espresso",
		"Flat White",
		"Cappuccino",
		"Frappuccino",
		"Latte",
	);

    my $bloom2 = BloomFilter->new(20, 2);
    for my $drink (@more_coffees) {
        $bloom2->add($drink);
    }

    my $bloom3 = $bloom2->union($bloom);
    dump_with('---Experiment #2---');
	dump_with($bloom3->lookup("Mocha"));
	dump_with($bloom3->lookup("Frappuccino"));
	dump_with($bloom3->estimate_dataset_size());

    my $bloom4 = $bloom2->intersection($bloom);
    dump_with("---Experiment #3---");
    dump_with($bloom4->lookup("Mocha"));
    dump_with($bloom4->lookup("Flat White"));
    dump_with($bloom4->estimate_dataset_size(16));
}

main();
