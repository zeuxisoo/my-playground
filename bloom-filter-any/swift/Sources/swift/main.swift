import Foundation
import CryptoKit
import CommonCrypto
import BigNumber

enum CustomError: Error {
    case valueError(String)
}

class BloomFilter {

    private var size: Int
    private var numberHashes: Int
    private var salt: String
    fileprivate var bitArray: [Int]

    public init(size: Int, numberHashes: Int, salt: String = "") {
        self.size = size
        self.numberHashes = numberHashes
        self.salt = salt
        self.bitArray = Array(repeating: 0, count: size)
        // self.bitArray = [Int](repeating: 0, count: size)
    }

    public func add(_ element: String) {
        for i in 0..<self.numberHashes {
            let digest = sha1("\(self.salt)\(element)\(i)")
            let index  = BInt(digest, radix: 16)! % BInt(self.size)

            self.bitArray[Int(index)] = 1
        }
    }

    public func lookup(_ element: String) -> Bool {
        for i in 0..<self.numberHashes {
            let digest = sha1("\(self.salt)\(element)\(i)")
            let index  = BInt(digest, radix: 16)! % BInt(self.size)

            if self.bitArray[Int(index)] == 0 {
                return false
            }
        }

        return true
    }

    public func estimateDatasetSize(_ precision: Int = 15) -> String {
        let m = self.size
        let k = self.numberHashes
        let n = -Double(m / k) * log(1 - Double(self.bitArray.reduce(0, +)) / Double(m))

        return String(format: "%.\(precision)f", n)
    }

    public func union(_ other: BloomFilter) throws -> BloomFilter {
        if self.size != other.size || self.numberHashes != other.numberHashes {
            throw CustomError.valueError("Both filters must have the same size and hash count")
        }

        let result = BloomFilter(size: self.size, numberHashes: self.numberHashes)
        result.bitArray = zip(self.bitArray, other.bitArray).map {
            $0.0 | $0.1
        }

        // var newBitArray = [Int]()
        // for (x, y) in zip(self.bitArray, other.bitArray) {
        //     newBitArray.append(x | y)
        // }
        // result.bitArray = newBitArray

        return result
    }

    public func intersection(_ other: BloomFilter) throws -> BloomFilter {
        if self.size != other.size || self.numberHashes != other.numberHashes {
            throw CustomError.valueError("Both filters must have the same size and hash count")
        }

        let result = BloomFilter(size: self.size, numberHashes: self.numberHashes)
        result.bitArray = zip(self.bitArray, other.bitArray).map { (x, y) in
            x & y
        }

        return result
    }

}

func sha1(_ value: String) -> String {
    let hashed: String

    if #available(macOS 10.15, *) {
        hashed = Insecure.SHA1.hash(data: value.data(using: .utf8)!).map {
            String(format: "%02x", $0)
        }.joined()
    }else{
        let data = Data()

        var digests = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA1(bytes.baseAddress, CC_LONG(data.count), &digests)
        }

        let hexBytes = digests.map {
            String(format: "%02hhx", $0)
        }

        hashed = hexBytes.joined()
    }

    return hashed
}

let coffees = [
    "Iced Coffee",
    "Iced Coffee with Milk",
    "Espresso",
    "Espresso Macchiato",
    "Flat White",
    "Latte Macchiato",
    "Cappuccino",
    "Mocha",
]

var bloom = BloomFilter(size: 20, numberHashes: 2, salt: "")
for drink in coffees {
    bloom.add(drink)
    print(bloom.bitArray)
}

print("---Experiment #1---")
print(bloom.lookup("Flat White"))
print(bloom.lookup("Americano"))
print(bloom.estimateDatasetSize())

//
let more_coffees = [
    "Iced Espresso",
    "Flat White",
    "Cappuccino",
    "Frappuccino",
    "Latte",
]

var bloom2 = BloomFilter(size: 20, numberHashes: 2)
for drink in more_coffees {
    bloom2.add(drink)
}

var bloom3 = try bloom2.union(bloom)
print("---Experiment #2---")
print(bloom3.lookup("Mocha"))
print(bloom3.lookup("Frappuccino"))
print(bloom3.estimateDatasetSize())

var bloom4 = try bloom2.intersection(bloom)
print("---Experiment #3---")
print(bloom4.lookup("Mocha"))
print(bloom4.lookup("Flat White"))
print(bloom4.estimateDatasetSize(16))
