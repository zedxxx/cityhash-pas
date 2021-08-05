// Copyright (c) 2011 Google, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// CityHash, by Geoff Pike and Jyrki Alakuijala
//
// http://code.google.com/p/cityhash/
//
// This file provides a few functions for hashing strings.  All of them are
// high-quality functions in the sense that they pass standard tests such
// as Austin Appleby's SMHasher.  They are also fast.
//
// For 64-bit x86 code, on short strings, we don't know of anything faster than
// CityHash64 that is of comparable quality.  We believe our nearest competitor
// is Murmur3.  For 64-bit x86 code, CityHash64 is an excellent choice for hash
// tables and most other hashing (excluding cryptography).
//
// For 64-bit x86 code, on long strings, the picture is more complicated.
// On many recent Intel CPUs, such as Nehalem, Westmere, Sandy Bridge, etc.,
// CityHashCrc128 appears to be faster than all competitors of comparable
// quality.  CityHash128 is also good but not quite as fast.  We believe our
// nearest competitor is Bob Jenkins' Spooky.  We don't have great data for
// other 64-bit CPUs, but for long strings we know that Spooky is slightly
// faster than CityHash on some relatively recent AMD x86-64 CPUs, for example.
//
// For 32-bit x86 code, we don't know of anything faster than CityHash32 that
// is of comparable quality.  We believe our nearest competitor is Murmur3A.
// (On 64-bit CPUs, it is typically faster to use the other CityHash variants.)
//
// Functions in the CityHash family are not suitable for cryptography.
//
// WARNING: This code has been only lightly tested on big-endian platforms!
// It is known to work well on little-endian platforms that have a small penalty
// for unaligned reads, such as current Intel and AMD moderate-to-high-end CPUs.
// It should work on all 32-bit and 64-bit platforms that allow unaligned reads;
// bug reports are welcome.
//
// By the way, for some hash functions, given strings a and b, the hash
// of a+b is easily derived from the hashes of a and b.  This property
// doesn't hold for any hash functions in this file.

unit CityHash;

interface

const
  CityHashLib = 'CityHash.dll';

{$IF CompilerVersion <= 18.5}
type
  NativeUInt = Cardinal;
{$IFEND}

type
  size_t   = NativeUInt;
  uint8_t  = Byte;
  uint16_t = Word;
  uint32_t = Cardinal;
  uint64_t = UInt64;

  uint128_t = record
    first: uint64_t;
    second: uint64_t;
  end;
  p_uint128_t = ^uint128_t;

function UInt128Low64(const x: p_uint128_t): uint64_t; inline;
function UInt128High64(const x: p_uint128_t): uint64_t; inline;

// Hash function for a byte array.
function CityHash64(const buf: pointer; len: size_t): uint64_t; cdecl; external CityHashLib;

// Hash function for a byte array. For convenience, a 64-bit seed is also hashed into the result.
function CityHash64WithSeed(const buf: pointer; len: size_t; seed: uint64_t): uint64_t; cdecl; external CityHashLib;

// Hash function for a byte array. For convenience, two seeds are also hashed into the result.
function CityHash64WithSeeds(const buf: pointer; len: size_t; seed0, seed1: uint64_t): uint64_t; cdecl; external CityHashLib;

// Hash function for a byte array.
function CityHash128(const buf: pointer; len: size_t): uint128_t; cdecl; external CityHashLib;

// Hash function for a byte array. For convenience, a 128-bit seed is also hashed into the result.
function CityHash128WithSeed(const buf: pointer; len: size_t; seed: uint128_t): uint128_t; cdecl; external CityHashLib;

// Hash function for a byte array. Most useful in 32-bit binaries.
function CityHash32(const buf: pointer; len: size_t): uint32_t; cdecl; external CityHashLib;

// Hash 128 input bits down to 64 bits of output.
// This is intended to be a reasonably good hash function.
function Hash128to64(const x: p_uint128_t): uint64_t; inline;

implementation

const
  kMul = $9ddfea08eb382d69;

function UInt128Low64(const x: p_uint128_t): uint64_t; inline;
begin
  Result := x.first;
end;

function UInt128High64(const x: p_uint128_t): uint64_t; inline;
begin
  Result := x.second;
end;

function Hash128to64(const x: p_uint128_t): uint64_t; inline;
var
  a, b: uint64_t;
begin
  // Murmur-inspired hashing.
  // const uint64 kMul = 0x9ddfea08eb382d69ULL;
  a := (UInt128Low64(x) xor UInt128High64(x)) * uint64_t(kMul);
  a := a xor (a shr 47);
  b := (UInt128High64(x) xor a) * uint64_t(kMul);
  b := b xor (b shr 47);
  b := b * uint64_t(kMul);
  Result := b;
end;

end.
