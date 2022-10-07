// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract BitMagicTest is Test {
    /// @dev Address of the BitMagic contract.
    BitMagic public bm;

    /// @dev Setup the testing environment.
    function setUp() public {
        bm = BitMagic(HuffDeployer.deploy("BitMagic"));
    }

    // Bitwise Basics

    /// @dev Test and_
    function testAnd_(uint256 x, uint256 y) public {
        assert(bm.and_(x, y) == x & y);
    }

    /// @dev Test or_
    function testOr_(uint256 x, uint256 y) public {
        assert(bm.or_(x, y) == x | y);
    }

    /// @dev Test xor_
    function testXor_(uint256 x, uint256 y) public {
        assert(bm.xor_(x, y) == x ^ y);
    }

    ///@dev Test not_
    function testNot_(uint256 x) public {
        assert(bm.not_(x) == ~x);
    }

    /// @dev Test shl_
    function testShl_(uint256 x, uint256 y) public {
        assert(bm.shl_(x, y) == x << y);
    }

    /// @dev Test shr_
    function testShr_(uint256 x, uint256 y) public {
        assert(bm.shr_(x, y) == x >> y);
    }

    // @dev Get Last N bits
    function testGetLastNBits(uint256 x, uint256 n) public {
        vm.assume((1 << n) >= 1);
        assert(bm.getLastNBits(x, n) == x & ((1 << n) - 1));
    }

    // @dev Get most significant Bit
    function testGetMostSignificantBit(uint256 x) public {
        uint256 expected;
        uint256 x_ = x;
        while (x_ > 0) {
            ++expected;
            x_ >>= 1;
        }
        console.log("expected", expected);
        console.log("actual", bm.getMostSignificantBit(x));
        assert(bm.getMostSignificantBit(x) == expected);
    }

    // @dev Get First N bits
    function testGetFirstNBits(uint256 x, uint256 n) public {
        uint256 x = uint256(1000);
        uint256 n = 0x2;
        uint256 len = bm.getMostSignificantBit(x);
        vm.assume((1 << n) >= 1);
        vm.assume(n <= len);
        uint256 mask = ((1 << n) - 1) << (len - n);
        uint256 expected = x & mask;
        assert(bm.getFirstNBits(x, n) == expected);
    }

    // @dev Is power of 2
    function testIsPowerOfTwo(uint256 x) public {
        bool expected = (x == 0) || ((x & (x - 1)) == 0);
        assert(bm.isPowerOfTwo(x) == expected);
    }

    function countSetBits(uint256 x) public returns (uint256) {
        uint256 count;
        while (x != 0) {
            x = x & (x - 1);
            ++count;
        }
        return count;
    }

    // @dev Count set bits
    function testCountSetBits(uint256 x) public {
        assert(bm.countSetBits(x) == countSetBits(x));
    }

    // BitMap

    function findNthBool(uint256 packedBool, uint256 position) public returns (bool) {
        return ((packedBool >> position) & 1 == 1);
    }

    // @dev test findNthBool
    function testFindNthBool(uint256 packedBool, uint256 position) public {
        assert(bm.findNthBool(packedBool, position) == findNthBool(packedBool, position));
    }

    function setNthBool(uint256 packedBool, uint256 position, bool value) public returns (uint256) {
        if (value) {
            packedBool |= (1 << position);
        } else {
            packedBool &= ~(1 << position);
        }
        return packedBool;
    }

    function testSetNthBool(uint256 packedBool, uint256 position, bool value) public {
        bound(position, 0, 256);
        assert(bm.setNthBool(packedBool, position, value) == setNthBool(packedBool, position, value));
    }

    // Extreme Basics - Part 1

    /// @dev Test sameSign
    // function testSameSign(int256 x, int256 y) public {
    function testSameSign() public {
        // vm.assume(x != 0 && y != 0);
        int256 x = -1;
        int256 y = -1;
        assert(bm.sameSign(x, y) == ((x ^ y) >= 0));
    }

    /// @dev Test isEven
    function testIsEven(uint256 x) public {
        assert(bm.isEven(x) == (x % 2 == 0));
    }

    /// @dev test invertSign using 2's complement
    function testInvertSign(int256 x) public {
        vm.assume(x != type(int256).min);
        assert(bm.invertSign(x) == -x);
    }

    // add1ToInteger with -(~x) is not so interesting in Huff since we use 2's complement to invert the sign

    // swap2Numbers with xor: a = a ^ b; b = b ^ a; a = a ^ b; also not interesting (overly complex) to do with Huff

    // turnOffNthBit, checkNthBit, toggleNthBit etc, done above w bitmaps findNthBool, setNthBool

    /// @dev test rightMostUnsetBit
    function testUnsetRightMostSetBit(uint256 x) public {
        uint256 expected;
        unchecked {
            expected = x & (x - 1);
        }
        assert(bm.rightMostUnsetBit(x) == expected);
    }

    /// @dev test findPositionOfRightmostSetBit
    function testFindPositionOfRightmostSetBit(uint256 x) public {
        uint256 rightMostSetBit = x ^ bm.rightMostUnsetBit(x);
        uint256 expected = bm.getMostSignificantBit(rightMostSetBit);
        assert(bm.findPositionOfRightmostSetBit(x) == expected);
    }

    function findPositionOfRightmostSetBit_Negation(uint256 x) public returns (uint256) {
        if (x & 1 == 1) {
            return 1; // Number is odd
        }

        uint256 num;
        unchecked {
            num = uint256(int256(x) & -int256(x));
        }
        return bm.getMostSignificantBit(num);
    }

    /// @dev test findPositionOfRightmostSetBit_Negation
    function testFindPositionOfRightmostSetBit_Negation(int256 x) public {
        vm.assume(x != type(int256).min);
        uint256 expected = findPositionOfRightmostSetBit_Negation(uint256(x));
        console.log(
            "+ + file: BitMagic.t.sol + line 182 + testFindPositionOfRightmostSetBit_Negation + expected", expected
        );
        console.log(
            "+ + file: BitMagic.t.sol + line 184 + testFindPositionOfRightmostSetBit_Negation + bm.findPositionOfRightmostSetBit_Negation(uint(x))",
            bm.findPositionOfRightmostSetBit_Negation(uint256(x))
        );
        assert(bm.findPositionOfRightmostSetBit_Negation(uint256(x)) == expected);
    }

    // Puzzles (Incorporating multiple tricks)

    function bitsToFlip(uint256 x, uint256 y) public pure returns (uint256 counter) {
        uint256 xoredNumber = x ^ y;
        while (xoredNumber != 0) {
            xoredNumber = xoredNumber & (xoredNumber - 1);
            ++counter;
        }
    }

    /// @dev test bitsToFlip
    function testBitsToFlip(uint256 x, uint256 y) public {
        assert(bm.bitsToFlip(x, y) == bitsToFlip(x, y));
    }

    function calculateXorToN(uint256 n) public pure returns (uint256 result) {
        for (uint256 i = 1; i <= n;) {
            result ^= i;
            unchecked {
                ++i;
            }
        }
    }

    /// @dev test calculateXorToN
    function testCalculateXorToN(uint8 n) public {
        assert(bm.calculateXorToN(n) == calculateXorToN(n));
    }

    /// @dev calculateXorToNEfficient
    function testCalculateXorToNEfficient(uint8 n) public {
        assert(bm.calculateXorToNEfficient(n) == calculateXorToN(n));
    }

    function findSumEqualToXor(uint8 n) public returns (uint256 counter) {
        for (uint256 i; i <= n; ++i) {
            if ((n ^ i) == (n + i)) {
                console.log(n, i);
                ++counter;
            }
        }
    }

    /// @dev test findSumEqualToXor
    function testFindSumEqualToXor(uint8 n) public {
        assert(uint256(bm.findSumEqualToXor(n)) == uint256(findSumEqualToXor(n)));
    }

    /// @dev test findSumEqualToXorEfficient
    function testFindSumEqualToXorEfficient(uint8 n) public {
        // function testFindSumEqualToXorEfficient() public {
        //     uint8 n = 2;
        console.log("findSumEqualToXor(n)", findSumEqualToXor(n));
        console.log("bm.findSumEqualToXorEfficient(n)", bm.findSumEqualToXorEfficient(n));
        assert(uint256(bm.findSumEqualToXorEfficient(n)) == uint256(findSumEqualToXor(n)));
    }

    function findMSB(uint256 n) public pure returns (uint256) {
        // Since this is uint256, this will have 256 bits. So we will have to take appropriate number of steps.
        // The number of ORs we do would be based on the bits present in number n.

        n |= (n >> 1); // Now starting 2 bits are set in n
        n |= (n >> 2); // Now starting 4 bits are set in n
        n |= (n >> 4); // Now starting 8 bits are set in n
        n |= (n >> 8); // Now starting 16 bits are set in n
        n |= (n >> 16); // Now starting 32 bits are set in n
        n |= (n >> 32); // Now starting 64 bits are set in n
        n |= (n >> 64); // Now starting 128 bits are set in n
        n |= (n >> 128); // Now starting 256 bits are set in n

        n += 1; // Now it's 1 set bit (higher than the original MSB) and rest are 0s

        return (n >> 1);
    }

    /// @dev test findMSB -- OPTIMIZED VERSION
    function testFindMSB(uint128 x) public {
        assert(bm.findMSB(x) == findMSB(x));
    }

    // Advanced problems solved via bit manipulations

    /// @dev test addTwoNumbers
    function testAddTwoNumbers(uint128 x, uint128 y) public {
        vm.assume((uint256(x) + uint(y)) <= type(uint64).max);
        uint256 actual = bm.addTwoNumbers(x, y);
        uint expected = uint256(x) + uint(y);
        assertEq(actual, expected);
    }
}

interface BitMagic {
    function and_(uint256, uint256) external returns (uint256);
    function or_(uint256, uint256) external returns (uint256);
    function xor_(uint256, uint256) external returns (uint256);
    function not_(uint256) external returns (uint256);
    function shl_(uint256, uint256) external returns (uint256);
    function shr_(uint256, uint256) external returns (uint256);
    function getLastNBits(uint256, uint256) external returns (uint256);
    function getFirstNBits(uint256, uint256) external returns (uint256);
    function getMostSignificantBit(uint256) external returns (uint256);
    function isPowerOfTwo(uint256) external returns (bool);
    function countSetBits(uint256) external returns (uint256);
    function findNthBool(uint256, uint256) external returns (bool);
    function setNthBool(uint256, uint256, bool) external returns (uint256);
    function sameSign(int256, int256) external returns (bool);
    function isEven(uint256) external returns (bool);
    function invertSign(int256) external returns (int256);
    function rightMostUnsetBit(uint256) external returns (uint256);
    function findPositionOfRightmostSetBit(uint256) external returns (uint256);
    function findPositionOfRightmostSetBit_Negation(uint256) external returns (uint256);
    function bitsToFlip(uint256, uint256) external returns (uint256);
    function calculateXorToN(uint256) external returns (uint256);
    function calculateXorToNEfficient(uint256) external returns (uint256);
    function findSumEqualToXor(uint256) external returns (uint256);
    function findSumEqualToXorEfficient(uint256) external returns (uint256);
    function findMSB(uint256) external returns (uint256);
    function addTwoNumbers(uint256, uint256) external returns (uint256);
}
