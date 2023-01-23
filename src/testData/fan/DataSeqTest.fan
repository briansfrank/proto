//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Jan 2023  Brian Frank  Creation
//

using util
using data
using haystack

**
** DataSeqTest
**
@Js
class DataSeqTest : Test
{
  Void testDict()
  {
    // basics
    verifyDict(env.emptyDict, [:])
    verifyDict(env.dict(["a":"Alpha"]), ["a":"Alpha"])
    verifyDict(env.dict(["a":"Alpha", "b":"Beta"]), ["a":"Alpha", "b":"Beta"])

    // map
    d := env.dict(["a":1, "b":2, "c":3, "d":4])
    verifyDictPairs(
      d.x.map(|Int x->Int| { x*2 }).collect,
      ["a":2, "b":4, "c":6, "d":8])

    // findAll
    verifyDictPairs(
      d.x.findAll(|Int x->Bool| { x.isOdd }).collect,
      ["a":1, "c":3])

    // findAll, map
    verifyDictPairs(
      d.x.findAll(|Int x->Bool| { x.isOdd }).map(|Int x->Int| { x+100 }).collect,
      ["a":101, "c":103])
  }

  Void verifyDict(DataDict d, Str:Obj map)
  {
    // isEmpty, get, each, trap
    verifyDictPairs(d, map)

    // identity x.map
    dup := d.x.map |x| { x }.collect
    verifyEq(d === dup, d.isEmpty)
    verifyDictPairs(dup, map)

    // identity x.findAll
    dup = d.x.findAll |x| { true }.collect
    verifyEq(d === dup, d.isEmpty)
    verifyDictPairs(dup, map)
  }

  Void verifyDictPairs(DataDict d, Str:Obj map)
  {
echo("-- verifyDict $d")
    // isEmpty
    verifyEq(d.isEmpty, map.isEmpty)

    // get
    map.each |v, n|
    {
      verifyEq(v, d.get(n))
    }

    // each, trap
    d.each |v, n|
    {
      verifyEq(v, map[n])
      verifySame(d.trap(n), v)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }
}