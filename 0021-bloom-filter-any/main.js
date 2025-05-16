const crypto = require('crypto');

class BloomFilter {

    size          = 0;
    number_hashes = 0;
    salt          = ''
    bit_array     = [];

    constructor(size, number_hashes, salt) {
        this.size          = size;
        this.number_hashes = number_hashes;
        this.salt          = salt;
        this.bit_array     = new Array(size).fill(0);
    }

    add(element) {
        for(let i=0; i<this.number_hashes; i++) {
            const digest = crypto.createHash('sha1').update(`${this.salt}${element}${i}`).digest('hex');
            const index = BigInt(`0x${digest}`) % BigInt(this.size);

            this.bit_array[index] = 1;
        }
    }

    lookup(element) {
        for(let i=0; i<this.number_hashes; i++) {
            const digest = crypto.createHash('sha1').update(`${this.salt}${element}${i}`).digest('hex');
            const index = BigInt(`0x${digest}`) % BigInt(this.size);

            if (this.bit_array[index] === 0) {
                return false;
            }
        }

        return true;
    }

    estimate_dataset_size() {
        const m = this.size;
        const k = this.number_hashes;
        const n = -(m / k) * Math.log(1 - this.bit_array.reduce((a, b) => a + b, 0) / m);

        return n;
    }

    union(other) {
        if (this.size !== other.size || this.number_hashes !== other.number_hashes) {
            throw new Error('Both filters must have the same size and hash count');
        }

        const result = new BloomFilter(this.size, this.number_hashes, '');
        result.bit_array = zip(this.bit_array, other.bit_array).map(bits => bits[0] | bits[1]);

        return result;
    }

    intersection(other) {
        if (this.size !== other.size || this.number_hashes !== other.number_hashes) {
            throw new Error('Both filters must have the same size and hash count');
        }

        const result = new BloomFilter(this.size, this.number_hashes, '');
        result.bit_array = zip(this.bit_array, other.bit_array).map(bits => bits[0] & bits[1]);

        return result;
    }

}

function zip(items1, items2) {
    const new_items = [];

    for(const [i, item] of Object.entries(items1)) {
        new_items.push([item, items2[i]]);
    }

    return new_items;
}

(() => {

    const coffees = [
        "Iced Coffee",
        "Iced Coffee with Milk",
        "Espresso",
        "Espresso Macchiato",
        "Flat White",
        "Latte Macchiato",
        "Cappuccino",
        "Mocha",
    ];

    const bloom = new BloomFilter(20, 2, '');
    for(const drink of coffees) {
        bloom.add(drink);

        dump(bloom.bit_array);
    }

    dump("---Experiment #1---");
    dump(bloom.lookup("Flat White"));
    dump(bloom.lookup("Americano"));
    dump(bloom.estimate_dataset_size());

    //
	const more_coffees = [
		'Iced Espresso',
		'Flat White',
		'Cappuccino',
		'Frappuccino',
		'Latte',
	]

	const bloom2 = new BloomFilter(20, 2, '')
	for(const drink of more_coffees) {
		bloom2.add(drink);
	}

	const bloom3 = bloom2.union(bloom);
	dump('---Experiment #2---');
	dump(bloom3.lookup('Mocha'));
	dump(bloom3.lookup('Frappuccino'));
	dump(bloom3.estimate_dataset_size());

    const bloom4 = bloom2.intersection(bloom);
	dump('---Experiment #3---');
	dump(bloom4.lookup('Mocha'));
	dump(bloom4.lookup('Flat White'));
	dump(bloom4.estimate_dataset_size());

    function dump(value) {
        const types = {
            'string' : value => value,
            'boolean': value => value === true ? 'true': 'false',
            'number' : value => value.toString(),
        };

        if (Array.isArray(value)) {
            console.log('[' + value.join(', ') + ']');
        }else{
            console.log(types[typeof value](value));
        }
    }

})();
