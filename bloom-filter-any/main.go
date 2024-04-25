package main

import (
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"math"
	"math/big"
	"strconv"
	"strings"
)

type BloomFilter struct {
	size         int
	numberHashes int
	salt         string
	BitArray     []int64
}

func newBloomFilter(size, numberHashes int, salt string) *BloomFilter {
	return &BloomFilter{
		size:         size,
		numberHashes: numberHashes,
		salt:         salt,
		BitArray:     make([]int64, size),
	}
}

func (bf *BloomFilter) Add(element string) {
	for i := 0; i < bf.numberHashes; i++ {
		digest := bf.sha1Hash(bf.salt + element + strconv.Itoa(i))
		index := new(big.Int).Mod(bf.hexToBigInt(digest), big.NewInt(20)).Uint64()

		bf.BitArray[index] = 1
	}
}

func (bf *BloomFilter) Lookup(element string) bool {
	for i := 0; i < bf.numberHashes; i++ {
		digest := bf.sha1Hash(bf.salt + element + strconv.Itoa(i))
		index := new(big.Int).Mod(bf.hexToBigInt(digest), big.NewInt(20)).Uint64()

		if bf.BitArray[index] == 0 {
			return false
		}
	}

	return true
}

func (bf BloomFilter) Union(other *BloomFilter) *BloomFilter {
	if bf.size != other.size || bf.numberHashes != other.numberHashes {
		panic("Both filters must have the same size and hash count")
	}

	newBitArray := []int64{}
	for _, item := range zip(bf.BitArray, other.BitArray) {
		if bits, ok := item.([]interface{}); ok {
			newBitArray = append(newBitArray, bits[0].(int64)|bits[1].(int64))
		}
	}

	result := newBloomFilter(bf.size, bf.numberHashes, "")
	result.BitArray = newBitArray

	return result
}

func (bf BloomFilter) Intersection(other *BloomFilter) *BloomFilter {
	if bf.size != other.size || bf.numberHashes != other.numberHashes {
		panic("Both filters must have the same size and hash count")
	}

	newBitArray := []int64{}
	for _, item := range zip(bf.BitArray, other.BitArray) {
		if bits, ok := item.([]interface{}); ok {
			newBitArray = append(newBitArray, bits[0].(int64)&bits[1].(int64))
		}
	}

	result := newBloomFilter(bf.size, bf.numberHashes, "")
	result.BitArray = newBitArray

	return result
}

func (bf BloomFilter) EstimateDatasetSize() float64 {
	m := float64(bf.size)         // cast float type for precision make sure return is not integer after calculation
	k := float64(bf.numberHashes) // same precision type in calculation
	n := -(m / k) * math.Log(1-float64(sum(bf.BitArray))/m)

	return n
}

func (bf BloomFilter) sha1Hash(value string) string {
	hashSha1 := sha1.New()
	hashSha1.Write([]byte(value))

	return hex.EncodeToString(hashSha1.Sum(nil))
}

func (bf BloomFilter) hexToBigInt(value string) *big.Int {
	num := new(big.Int)
	num.SetString(value, 16)

	return num
}

func sum(values []int64) int64 {
	sum := int64(0)

	for _, value := range values {
		sum += value
	}

	return sum
}

/*
	func zip(items1, items2 []int64) [][]int64 {
		newItems := [][]int64{}

		for i, item := range items1 {
			newItems = append(newItems, []int64{ item, items2[i] })
		}

		return newItems
	}
*/
func zip[T, U any](items1 []T, items2 []U) []interface{} {
	var newItems []interface{}

	for i := 0; i < len(items1) && i < len(items2); i++ {
		newItems = append(newItems, []interface{}{items1[i], items2[i]})
	}

	return newItems
}

/*
func dump[T any](value T) {
	switch v := any(value).(type) {
	case string, float64:
		fmt.Println(v)
	case bool:
		if v {
			fmt.Println("true")
		} else {
			fmt.Println("false")
		}
	case []int64:
		bits := []string{}
		for _, bit := range v {
			bits = append(bits, strconv.Itoa(int(bit)))
		}
		fmt.Printf("[%s]\n", strings.Join(bits, ", "))
	}
}
*/
func dump(value interface{}) {
	switch v := value.(type) {
	case string, float64:
		fmt.Println(v)
	case bool:
		if v {
			fmt.Println("true")
		} else {
			fmt.Println("false")
		}
	case []int64:
		bits := []string{}
		for _, bit := range v {
			bits = append(bits, strconv.Itoa(int(bit)))
		}
		fmt.Printf("[%s]\n", strings.Join(bits, ", "))
	}
}

func main() {
	coffees := []string{
		"Iced Coffee",
		"Iced Coffee with Milk",
		"Espresso",
		"Espresso Macchiato",
		"Flat White",
		"Latte Macchiato",
		"Cappuccino",
		"Mocha",
	}

	bloom := newBloomFilter(20, 2, "")
	for _, drink := range coffees {
		bloom.Add(drink)
		dump(bloom.BitArray)
	}

	dump("---Experiment #1---")
	dump(bloom.Lookup("Flat White"))
	dump(bloom.Lookup("Americano"))
	dump(bloom.EstimateDatasetSize())

	more_coffees := []string{
		"Iced Espresso",
		"Flat White",
		"Cappuccino",
		"Frappuccino",
		"Latte",
	}

	bloom2 := newBloomFilter(20, 2, "")
	for _, drink := range more_coffees {
		bloom2.Add(drink)
	}

	bloom3 := bloom2.Union(bloom)
	dump("---Experiment #2---")
	dump(bloom3.Lookup("Mocha"))
	dump(bloom3.Lookup("Frappuccino"))
	dump(bloom3.EstimateDatasetSize())

	bloom4 := bloom2.Intersection(bloom)
	dump("---Experiment #3---")
	dump(bloom4.Lookup("Mocha"))
	dump(bloom4.Lookup("Flat White"))
	dump(bloom4.EstimateDatasetSize())
}
