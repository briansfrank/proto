//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Feb 2023  Brian Frank  Creation
//

using util
using data2
using haystack

**
** DataParseTest
**
@Js
class DataParseTest : AbstractDataTest
{

//////////////////////////////////////////////////////////////////////////
// Scalars
//////////////////////////////////////////////////////////////////////////

  Void testScalars()
  {
    verifyScalar(Str<|"hi"|>, "hi")
    verifyScalar(Str<|Bool "true"|>, true)
    verifyScalar(Str<|Int "123"|>, 123)
    verifyScalar(Str<|Duration "123sec"|>, 123sec)
    verifyScalar(Str<|Number "123kW"|>, n(123, "kW"))
    verifyScalar(Str<|Str "123"|>, "123")
    verifyScalar(Str<|Date "2023-02-24"|>, Date("2023-02-24"))
    verifyScalar(Str<|Time "02:30:00"|>, Time("02:30:00"))
    verifyScalar(Str<|Ref "abc"|>, Ref("abc"))
    verifyScalar(Str<|Version "1.2.3"|>, Version("1.2.3"))
    verifyScalar(Str<|Uri "file.txt"|>, `file.txt`)
    verifyScalar(Str<|DateTime "2023-02-24T10:51:47.21-05:00 New_York"|>, DateTime("2023-02-24T10:51:47.21-05:00 New_York"))
  }

  Void verifyScalar(Str src, Obj? expected)
  {
    actual := compileData(src)
    // echo("$actual [$actual.typeof]")
    verifyEq(actual, expected)
  }

//////////////////////////////////////////////////////////////////////////
// Dicts
//////////////////////////////////////////////////////////////////////////

  Void testDicts()
  {
    // spec-less
    verifyDict(Str<|{}|>, [:])
    verifyDict(Str<|Dict {}|>, [:])
    verifyDict(Str<|{foo}|>, ["foo":m])
    verifyDict(Str<|{foo, bar}|>, ["foo":m, "bar":m])
    verifyDict(Str<|{dis:"Hi", mark}|>, ["dis":"Hi", "mark":m])

    // LibOrg
    verifyDict(Str<|LibOrg {}|>, [:], "sys::LibOrg")
    verifyDict(Str<|sys::LibOrg {}|>, [:], "sys::LibOrg")
    verifyDict(Str<|LibOrg { dis:"Acme" }|>, ["dis":"Acme"], "sys::LibOrg")
    verifyDict(Str<|LibOrg { dis:"Acme", uri:Uri "http://acme.com" }|>, ["dis":"Acme", "uri":`http://acme.com`], "sys::LibOrg")
  }

  Void verifyDict(Str src, Str:Obj expected, Str type := "sys::Dict")
  {
    DataDict actual := compileData(src)
    // echo("-- $actual [$actual.spec]")
    verifySame(actual.spec, env.type(type))
    if (expected.isEmpty && type == "sys::Dict")
    {
      verifyEq(actual.isEmpty, true)
      verifySame(actual, env.emptyDict)
      return
    }
    verifyDictEq(actual, expected)
  }

}