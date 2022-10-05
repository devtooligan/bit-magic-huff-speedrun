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
        while ((x_ >>= 1) > 0) {
            ++expected;
        }
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


    function countSetBits(uint x) public returns(uint) {
        uint count;
        while (x != 0) {
            x = x & (x-1);
            ++count;
        }
        return count;
    }

    // @dev Count set bits
    function testCountSetBits(uint256 x) public {
        assert(bm.countSetBits(x) == countSetBits(x));
    }

    // BitMap

    function findNthBool(uint packedBool, uint position) public returns (bool) {
        return ((packedBool >> position) & 1 == 1);
    }

    // @dev test findNthBool
    function testFindNthBool(uint256 packedBool, uint256 position) public {
        assert(bm.findNthBool(packedBool, position) == findNthBool(packedBool, position));
    }

    function setNthBool(uint packedBool, uint position, bool value) public returns (uint) {
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
}
