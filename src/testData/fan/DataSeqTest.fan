//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Jan 2023  Brian Frank  Creation
//

using util
using data
using haystackx

**
** DataSeqTest
**
@Js
class DataSeqTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Factory
//////////////////////////////////////////////////////////////////////////

  Void testFactory()
  {
    // null is empty seq
    verifySame(env.seq(null), env.emptyDict)
    verifySame(env.seq(Str:Obj?[:]), env.emptyDict)
    verifySame(env.seq([:]), env.emptyDict)

    // lists
    verifyList(env.seq([,]), [,])
    verifyList(env.seq([1, 2, 3]), [1, 2, 3])

    // maps w/ string keys are dicts
    verifyDict(env.seq(["a":1, "b":2]), ["a":1, "b":2])

    // maps w/ non-string keys are dicts
    verifyList(env.seq([1:"a"]), ["a"])

    // anything else is single sequence
    verifyList(env.seq("foo"), ["foo"])
  }

//////////////////////////////////////////////////////////////////////////
// List
//////////////////////////////////////////////////////////////////////////

  Void testList()
  {
    verifyList(env.seq([,]), [,])
    verifyList(env.seq(["a"]), ["a"])
    verifyList(env.seq(["a", "b"]), ["a", "b"])
    verifyList(env.seq(["a", null, "b"]), ["a", null, "b"])
  }

  Void verifyList(DataSeq seq, Obj?[] items)
  {
    // type
    verifySame(seq.type, env.type("sys.List"))
    verifyEq(seq.typeof.qname, "dataEnv::MDataList")

    // isEmpty, seqEach, seqEachWhile
    verifySeq(seq, items)

    // map
    s := env.seq([1, 2, 3, 4])
    verifySeqItems(
      s.x.seqMap |Int x->Int| { x* 2 }.collect,
      [2, 4, 6, 8])

    // findAll
    verifySeqItems(
      s.x.seqFindAll |Int x->Bool| { x.isEven }.collect,
      [2, 4])

    // map, findAll
    verifySeqItems(
      s.x.seqFindAll |Int x->Bool| { x.isEven }.seqMap |Int x->Int| { x+100 }.collect,
      [102, 104])
  }

//////////////////////////////////////////////////////////////////////////
// Dict
//////////////////////////////////////////////////////////////////////////

  Void testDict()
  {
    // basics
    verifyDict(env.emptyDict, [:])
    verifyDict(env.dict(null), [:])
    verifyDict(env.dict(["a":"Alpha"]), ["a":"Alpha"])
    verifyDict(env.dict(["a":"Alpha", "b":"Beta"]), ["a":"Alpha", "b":"Beta"])

    // map
    d := env.dict(["a":1, "b":2, "c":3, "d":4])
    verifyDictPairs(
      d.x.seqMap(|Int x->Int| { x*2 }).collect,
      ["a":2, "b":4, "c":6, "d":8])

    // findAll
    verifyDictPairs(
      d.x.seqFindAll(|Int x->Bool| { x.isOdd }).collect,
      ["a":1, "c":3])

    // findAll, map
    verifyDictPairs(
      d.x.seqFindAll(|Int x->Bool| { x.isOdd }).seqMap(|Int x->Int| { x+100 }).collect,
      ["a":101, "c":103])

    // add
    verifyDictPairs(d.x.add("e", 5).collect, ["a":1, "b":2, "c":3, "d":4, "e":5])
    verifyErr(ArgErr#) { d.x.add("a", 5).collect }

    // set
    verifyDictPairs(d.x.set("e", 5).collect, ["a":1, "b":2, "c":3, "d":4, "e":5])
    verifyDictPairs(d.x.set("a", 5).collect, ["a":5, "b":2, "c":3, "d":4])

    // rename
    verifySame(d.x.rename("e", "x").collect, d)
    verifyDictPairs(d.x.rename("e", "x").collect, ["a":1, "b":2, "c":3, "d":4])
    verifyDictPairs(d.x.rename("a", "x").collect, ["x":1, "b":2, "c":3, "d":4])

    // remove
    verifySame(d.x.remove("e").collect, d)
    verifyDictPairs(d.x.remove("e").collect, ["a":1, "b":2, "c":3, "d":4])
    verifyDictPairs(d.x.remove("c").collect, ["a":1, "b":2, "d":4])
  }

  Void verifyDict(Dict d, Str:Obj map)
  {
    // type
    verifySame(d.type, env.type("sys.Dict"))
    verifyEq(d === env.emptyDict, d.isEmpty)

    // isEmpty, get, each, trap
    verifyDictPairs(d, map)

    // identity x.map
    dup := d.x.seqMap |x| { x }.collect
    verifyEq(d === dup, d.isEmpty)
    verifyDictPairs(dup, map)

    // identity x.findAll
    dup = d.x.seqFindAll |x| { true }.collect
    verifyEq(d === dup, d.isEmpty)
    verifyDictPairs(dup, map)
  }

  Void verifyDictPairs(Dict d, Str:Obj map)
  {
    // as sequence
    verifySeq(d, map.vals)

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

  Void verifySeq(DataSeq seq, Obj?[] items)
  {
    verifySeqItems(seq, items)

    // identity collect
    verifySame(seq.x.collect, seq)

    // identity x.map
    dup := seq.x.seqMap |x| { x }.collect
    verifySame(dup.type, seq.type)
    verifySeqItems(dup, items)

    // identity x.findAll
    dup = seq.x.seqFindAll |x| { true }.collect
    verifySame(dup.type, seq.type)
    verifySeqItems(dup, items)
  }

  Void verifySeqItems(DataSeq seq, Obj?[] items)
  {
    // isEmpty
    verifyEq(seq.isEmpty, items.isEmpty)

    // seqEach
    i := 0
    seq.x.seqEach |v|
    {
      verifyEq(v, items[i++])
    }

    // seqEachWhile
    i = 0
    seq.x.seqEachWhile |v|
    {
      verifyEq(v, items[i++])
      return null
    }
  }
}