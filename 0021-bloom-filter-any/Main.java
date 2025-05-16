import java.math.BigInteger;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

class BloomFilter {

    protected int size;
    protected int numberHashes;
    protected String salt;
    protected int[] bitArray;

    public BloomFilter(int size, int numberHashes, String salt) {
        var bitArray = new int[size];
        Arrays.fill(bitArray, 0);

        this.size         = size;
        this.numberHashes = numberHashes;
        this.salt         = salt;
        this.bitArray     = bitArray;
    }

    public BloomFilter(int size, int numberHashes) {
        this(size, numberHashes, "");
    }

    public void add(String element) throws NoSuchAlgorithmException, UnsupportedEncodingException {
        for(var i=0; i<this.numberHashes; i++) {
            var digest = this.sha1Hash(this.salt + element + i);
            var index = this.hexToBigInteger(digest).mod(BigInteger.valueOf(20));

            this.bitArray[index.intValue()] = 1;
        }
    }

    public Boolean lookup(String element) throws NoSuchAlgorithmException, UnsupportedEncodingException {
        for(var i=0; i<this.numberHashes; i++) {
            var digest = this.sha1Hash(this.salt + element + i);
            var index = this.hexToBigInteger(digest).mod(BigInteger.valueOf(20));

            if (this.bitArray[index.intValue()] == 0) {
                return false;
            }
        }

        return true;
    }

    public Double estimateDatasetSize() {
        var m = (double) this.size;         // cast float type for precision make sure return is not integer after calculation
        var k = (double) this.numberHashes; // same precision type in calculation
        var n = -(m / k) * Math.log(1 - IntStream.of(this.bitArray).sum() / m);

        return n;
    }

    public BloomFilter union(BloomFilter other) throws Exception {
        if (this.size != other.size || this.numberHashes != other.numberHashes) {
            throw new Exception("Both filters must have the same size and hash count");
        }

        var newBitArray = new int[this.size];
        var zipBitArray = this.zip1(this.bitArray, other.bitArray);
        for(var i = 0; i<bitArray.length; i++) {
            var bits = zipBitArray.get(i);

            newBitArray[i] = bits[0] | bits[1];
        }

        var result = new BloomFilter(this.size, this.numberHashes);
        result.bitArray = newBitArray;

        return result;
    }

    public BloomFilter intersection(BloomFilter other) throws Exception {
        if (this.size != other.size || this.numberHashes != other.numberHashes) {
            throw new Exception("Both filters must have the same size and hash count");
        }

        // Method zip2 return []int not List<Int>
        //
        // var newBitArray = new int[this.size];
        // var zipBitArray = this.zip2(this.bitArray, other.bitArray);
        // for(var i = 0; i<bitArray.length; i++) {
        //     var bits = zipBitArray[i];
        //     newBitArray[i] = bits[0] & bits[1];
        // }

        var result = new BloomFilter(this.size, this.numberHashes);
        result.bitArray = this.zipAndIntersect(this.bitArray, other.bitArray);
        // result.bitArray = newBitArray; // for zip2 version

        return result;
    }

    protected String sha1Hash(String value) throws NoSuchAlgorithmException, UnsupportedEncodingException {
        var md = MessageDigest.getInstance("SHA-1");
        md.reset();
        md.update(value.getBytes("UTF-8"));

        return new BigInteger(1, md.digest()).toString(16); // positive number
    }

    protected BigInteger hexToBigInteger(String value) {
        return new BigInteger(value, 16);
    }

    protected List<int[]> zip1(int[] items1, int[] items2) {
        return IntStream
            .range(0, items1.length)
            .mapToObj(i -> new int[]{items1[i], items2[i]})
            .toList();
    }

    // protected int[][] zip2(int[] items1, int[] items2) {
    //     return IntStream
    //         .range(0, items1.length)
    //         .mapToObj(i -> new int[]{items1[i], items2[i]})
    //         .toArray(int[][]::new);
    // }

    protected int[] zipAndIntersect(int[] items1, int[] items2) {
        return IntStream
            .range(0, items1.length)
            .map(i -> items1[i] & items2[i])
            .toArray();
    }

}

// execution single file >= jdk 11
// - edit file move the `main' class to first class above other classes
// - run: `java Main.java`
public class Main {

    public static void main(String[] args) throws NoSuchAlgorithmException, UnsupportedEncodingException, Exception {
        var coffees = Arrays.asList(
            "Iced Coffee",
            "Iced Coffee with Milk",
            "Espresso",
            "Espresso Macchiato",
            "Flat White",
            "Latte Macchiato",
            "Cappuccino",
            "Mocha"
        );

        var bloom = new BloomFilter(20, 2);
        for(var drink : coffees) {
            bloom.add(drink);
            dump(bloom.bitArray);
        }

        dump("---Experiment #1---");
        dump(bloom.lookup("Flat White"));
        dump(bloom.lookup("Americano"));
        dump(bloom.estimateDatasetSize());

        //
        var more_coffees = Arrays.asList(
            "Iced Espresso",
            "Flat White",
            "Cappuccino",
            "Frappuccino",
            "Latte"
        );

        var bloom2 = new BloomFilter(20, 2);
        for(var drink : more_coffees) {
            bloom2.add(drink);
        }

        var bloom3 = bloom2.union(bloom);
        dump("---Experiment #2---");
        dump(bloom3.lookup("Mocha"));
        dump(bloom3.lookup("Frappuccino"));
        dump(bloom3.estimateDatasetSize());

        var bloom4 = bloom2.intersection(bloom);
        dump("---Experiment #3---");
        dump(bloom4.lookup("Mocha"));
        dump(bloom4.lookup("Flat White"));
        dump(bloom4.estimateDatasetSize());
    }

    public static <T> void dump(T value) throws Exception {
        if (value instanceof int[]) {
            var joinValue = Arrays
                .stream((int[]) value)
                .mapToObj(String::valueOf)
                .collect(Collectors.joining(", "));

            System.out.println("[" + joinValue  + "]");
        }

        if (value instanceof String) {
            System.out.println((String) value);
        }

        if (value instanceof Boolean) {
            System.out.println((Boolean) value ? "true" : "false");
        }

        if (value instanceof Double) {
            System.out.println((Double) value);
        }
    }

}
