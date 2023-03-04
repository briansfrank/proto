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
** DataCompileTest
**
@Js
class DataCompileTest : AbstractDataTest
{

//////////////////////////////////////////////////////////////////////////
// Scalars
//////////////////////////////////////////////////////////////////////////

  Void testScalars()
  {
    verifyScalar("sys::Str",      Str<|"hi"|>, "hi")
    verifyScalar("sys::Str",      Str<|Str "123"|>, "123")
    verifyScalar("sys::Str",      Str<|sys::Str "123"|>, "123")
    verifyScalar("sys::Bool",     Str<|Bool "true"|>, true)
    verifyScalar("sys::Int",      Str<|Int "123"|>, 123)
    verifyScalar("sys::Duration", Str<|Duration "123sec"|>, 123sec)
    verifyScalar("sys::Number",   Str<|Number "123kW"|>, n(123, "kW"))
    verifyScalar("sys::Date",     Str<|Date "2023-02-24"|>, Date("2023-02-24"))
    verifyScalar("sys::Time",     Str<|Time "02:30:00"|>, Time("02:30:00"))
    verifyScalar("sys::Ref",      Str<|Ref "abc"|>, Ref("abc"))
    verifyScalar("sys::Version",  Str<|Version "1.2.3"|>, Version("1.2.3"))
    verifyScalar("sys::Version",  Str<|sys::Version "1.2.3"|>, Version("1.2.3"))
    verifyScalar("sys::Uri",      Str<|Uri "file.txt"|>, `file.txt`)
    verifyScalar("sys::DateTime", Str<|DateTime "2023-02-24T10:51:47.21-05:00 New_York"|>, DateTime("2023-02-24T10:51:47.21-05:00 New_York"))
    verifyScalar("sys::DateTime", Str<|DateTime "2023-03-04T12:26:41.495Z"|>, DateTime("2023-03-04T12:26:41.495Z UTC"))

    // whitespace
    verifyScalar("sys::Date",
         Str<|Date
                 "2023-03-04"
              |>, Date("2023-03-04"))
    verifyScalar("sys::Date",
         Str<|Date


              "2023-03-04"
              |>, Date("2023-03-04"))
  }

  Void verifyScalar(Str qname, Str src, Obj? expected)
  {
    actual := compileData(src)
    verifyEq(actual, expected)

    type := env.typeOf(actual)
    verifyEq(type.qname, qname)

    pattern := type.get("pattern")
    if (pattern != null && !src.contains("\n"))
    {
      sp := src.index(" ")
      if (src[sp+1] != '"' || src[-1] != '"') fail(src)
      str := src[sp+2..-2]
      regex := Regex(pattern)
      verifyEq(regex.matches(str), true)
    }
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

    // whitespace
    verifyDict(Str<|LibOrg
                    {

                    }|>, [:], "sys::LibOrg")
    verifyDict(Str<|LibOrg


                                   {

                    }|>, [:], "sys::LibOrg")
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