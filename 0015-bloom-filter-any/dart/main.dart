import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class BloomFilter {
    late final int size;
    late final int numberHashes;
    late final String salt;
    late List<int> bitArray;

    BloomFilter(int size, int numberHashes, String salt) {
        this.size         = size;
        this.numberHashes = numberHashes;
        this.salt         = salt;
        this.bitArray     = List<int>.filled(size, 0, growable: true);
    }

    add(String element) {
        for(var i=0; i<numberHashes; i++) {
            var bytes  = utf8.encode("${salt}${element}${i}");
            var digest = sha1.convert(bytes).toString();
            var index  = BigInt.parse(digest, radix: 16) % BigInt.from(size);

            bitArray[index.toInt()] = 1;
        }
    }

    bool lookup(String element) {
        for(var i=0; i<numberHashes; i++) {
            var bytes  = utf8.encode("${salt}${element}${i}");
            var digest = sha1.convert(bytes).toString();
            var index  = BigInt.parse(digest, radix: 16) % BigInt.from(size);

            if (bitArray[index.toInt()] == 0) {
                return false;
            }
        }

        return true;
    }

    double estimateDatasetSize() {
        var m = size;
        var k = numberHashes;
        var n = -(m / k) * log(1 - bitArray.fold(0, (previous, current) => previous + current) / m);

        return n;
    }

    BloomFilter union(BloomFilter other) {
        if (size != other.size || numberHashes != other.numberHashes) {
            throw 'Both filters must have the same size and hash count';
        }

        var result = BloomFilter(size, numberHashes, '');
        result.bitArray = [for(var [x, y] in zip(bitArray, other.bitArray)) x | y];

        return result;
    }

    BloomFilter intersection(BloomFilter other) {
        if (size != other.size || numberHashes != other.numberHashes) {
            throw 'Both filters must have the same size and hash count';
        }

        var result = BloomFilter(size, numberHashes, '');
        result.bitArray = [for(var [x, y] in zip(bitArray, other.bitArray)) x & y];

        return result;
    }
}

List<List<int>> zip(List<int> items1, List<int> items2) {
    /*
    List<List<int>> newItems = List.empty(growable: true);

    for(var i=0;i<items1.length; i++) {
        newItems.add([items1[i], items2[i]]);
    }

    return newItems;
    */
    return [for(var i=0; i<items1.length; i++) [items1[i], items2[i]]];
}

void main() {
    const coffees = [
        'Iced Coffee',
    	'Iced Coffee with Milk',
    	'Espresso',
    	'Espresso Macchiato',
    	'Flat White',
    	'Latte Macchiato',
    	'Cappuccino',
    	'Mocha',
    ];

    var bloom = BloomFilter(20, 2, '');
    for(final drink in coffees) {
        bloom.add(drink);
        print(bloom.bitArray);
    }

    print("---Experiment #1---");
    print(bloom.lookup("Flat White"));
    print(bloom.lookup("Americano"));
    print(bloom.estimateDatasetSize());

    //
    const more_coffees = [
        'Iced Espresso',
        'Flat White',
        'Cappuccino',
        'Frappuccino',
        'Latte',
    ];

    var bloom2 = BloomFilter(20, 2, '');
    for(var drink in more_coffees) {
        bloom2.add(drink);
    }

    var bloom3 = bloom2.union(bloom);
    print('---Experiment #2---');
	print(bloom3.lookup('Mocha'));
	print(bloom3.lookup('Frappuccino'));
	print(bloom3.estimateDatasetSize());

    var bloom4 = bloom2.intersection(bloom);
    print('---Experiment #3---');
	print(bloom4.lookup('Mocha'));
	print(bloom4.lookup('Flat White'));
	print(bloom4.estimateDatasetSize());
}
