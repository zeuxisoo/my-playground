use sha1::{Sha1, Digest /* for `new/0` from CoreWrapper<Sha1Core> */};
use num_bigint::BigInt;
use num_traits::cast::ToPrimitive;

// extern crate hex; // auto now

//
trait Sha1Hash {
    fn sha1_hash(&self, value: &str) -> String;
}

//
#[derive(Clone)]
struct BloomFilter {
    size: usize,
    number_hashes: i32,
    salt: String,
    bit_array: Vec<i32>,
}

impl BloomFilter {

    pub fn new(size: usize, number_hashes: i32) -> Self {
        Self::new_with_salt(size, number_hashes, "")
    }

    pub fn new_with_salt(size: usize, number_hashes: i32, salt: &str) -> Self {
        Self {
            size,
            number_hashes,
            salt: salt.to_string(),
            bit_array: vec![0 as i32; size],
        }
    }

    pub fn add(&mut self, element: &str) {
        for i in 0..self.number_hashes {
            let digest = self.sha1_hash(format!("{salt}{element}{i}", salt=self.salt).as_str());
            let index = BigInt::parse_bytes(digest.as_bytes(), 16).unwrap() % self.size;

            self.bit_array[index.to_usize().unwrap()] = 1;
        }
    }

    pub fn lookup(&self, element: &str) -> bool {
        for i in 0..self.number_hashes {
            let digest = self.sha1_hash(format!("{salt}{element}{i}", salt=self.salt).as_str());
            let index = BigInt::parse_bytes(digest.as_bytes(), 16).unwrap() % self.size;

            if self.bit_array[index.to_usize().unwrap()] == 0 {
                return false
            }
        }

        true
    }

    pub fn estimate_dataset_size(&self) -> f64 {
        let m = self.size as i32;
        let k = self.number_hashes;
        let n = -(m / k) as f64 * (1 as f64 - self.bit_array.iter().sum::<i32>() as f64 / m as f64).log(std::f64::consts::E);

        // println!("{n:.15}");
        n
    }

    pub fn union(&self, other: BloomFilter) -> Self {
        if self.size != other.size || self.number_hashes != other.number_hashes {
            panic!("Both filters must have the same size and hash count")
        }

        /*
            let zipped_bit_array = self.bit_array.iter().zip(other.bit_array.iter()).collect::<Vec<_>>();
            let zipped_bit_array = self.bit_array.iter().zip(other.bit_array.iter()).collect::<Vec<(&i32, &i32)>>();
            let zipped_bit_array: [(&i32, &i32); 20] = self.bit_array.iter().zip(other.bit_array.iter()).collect::<Vec<_>>().try_into().unwrap();
            let zipped_bit_array: [(&i32, &i32); 20] = self.bit_array.iter().zip(other.bit_array.iter()).collect::<Vec<(&i32, &i32)>>().try_into().unwrap();

            let zipped_bit_array  = self.bit_array.iter().zip(other.bit_array.iter()).collect::<Vec<_>>();
            let mut new_bit_array = vec![];

            for item in zipped_bit_array {
                new_bit_array.push(item.0 | item.1);
            }
         */

        /*
            let new_bit_array = self.bit_array.iter()
                .zip(other.bit_array.iter())
                .map(|item| item.0 | item.1)
                .collect::<Vec<_>>();
         */

        let new_bit_array = self.bit_array.iter()
            .zip(other.bit_array.iter())
            .map(|(x, y)| x | y)
            .collect::<Vec<_>>();

        let mut result = Self::new(self.size, self.number_hashes);
        result.bit_array = new_bit_array;

        result
    }

    pub fn intersection(&self, other: BloomFilter) -> Self {
        if self.size != other.size || self.number_hashes != other.number_hashes {
            panic!("Both filters must have the same size and hash count")
        }

        Self {
            size: self.size,
            number_hashes: self.number_hashes,
            salt: "".to_string(),
            bit_array: self.bit_array.iter()
                .zip(other.bit_array.iter())
                .map(|(x, y)| x & y)
                .collect::<Vec<_>>(),
        }
    }

}

//
impl Sha1Hash for BloomFilter {

    fn sha1_hash(&self, value: &str) -> String {
        let mut hasher = Sha1::new();
        hasher.update(value);

        hex::encode(hasher.finalize())
    }

}

//
#[allow(dead_code)]
fn type_of<T>(_: &T) -> String {
    return format!("{}", std::any::type_name::<T>())
}

fn main() {
    let coffees = [
        "Iced Coffee",
        "Iced Coffee with Milk",
        "Espresso",
        "Espresso Macchiato",
        "Flat White",
        "Latte Macchiato",
        "Cappuccino",
        "Mocha",
    ];

    let mut bloom = BloomFilter::new(20, 2);
    for drink in coffees.iter() {
        bloom.add(drink);
        println!("{:?}", bloom.bit_array);
    }

    println!("{}", "---Experiment #1---");
    println!("{}", bloom.lookup("Flat White"));
    println!("{}", bloom.lookup("Americano"));
    println!("{}", bloom.estimate_dataset_size());

    let more_coffees = [
        "Iced Espresso",
        "Flat White",
        "Cappuccino",
        "Frappuccino",
        "Latte",
    ];

    let mut bloom2 = BloomFilter::new(20, 2);
    for i in 0..more_coffees.len() {
        bloom2.add(more_coffees[i]);
    }

    let bloom3 = bloom2.union(bloom.clone());
    println!("{}", "---Experiment #2---");
    println!("{}", bloom3.lookup("Mocha"));
    println!("{}", bloom3.lookup("Frappuccino"));
    println!("{}", bloom3.estimate_dataset_size());

    let bloom4 = bloom2.intersection(bloom.clone());
    println!("{}", "---Experiment #3---");
    println!("{}", bloom4.lookup("Mocha"));
    println!("{}", bloom4.lookup("Flat White"));
    println!("{}", bloom4.estimate_dataset_size());
}
