//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Jan 2023  Brian Frank  Creation
//

using util
using data

**
** DataSetTest
**
@Js
class DataSetTest : Test
{
//////////////////////////////////////////////////////////////////////////
// Factory
//////////////////////////////////////////////////////////////////////////

  Void testFactory()
  {
    // empty list
    set := env.set(DataDict[,])
    verifySetRecs(set, Str:DataDict[:])

    // empty map
    set = env.set(Str:DataDict[:])
    verifySetRecs(set, Str:DataDict[:])

    // map with 1 item
    map := ["foo":env.dict(["dis":"A"])]
    set = env.set(map)
    verifySetRecs(set, map)

    // map with multiple items
    map = ["foo":env.dict(["dis":"A"]), "bar":env.dict(["dis":"B"])]
    set = env.set(map)
    verifySetRecs(set, map)

    // list with items
    list := [env.dict(["dis":"A"]), env.dict(["dis":"B"])]
    set = env.set(list)
    map = set.toMap
    verifySetRecs(set, set.toMap)
  }

  Void verifySetRecs(DataSet set, Obj:DataDict recs)
  {
    verifyEq(set.size, recs.size)
    got := 0
    set.each |rec, key| { verifySame(rec, recs[key]); got++ }
    verifyEq(got, recs.size)
    recs.each |rec, key| { verifySame(rec, set.get(key)) }
  }

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  Void testRead()
  {
    src := Str<|a: {dis:"Alpha"}
                b: {dis:"Beta"}
                |>
    set := env.read(src.in, MimeType("text/pog"))
set.dump
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }

}