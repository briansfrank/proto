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
    verifyScalar("sys::Int",      Str<|Int 123|>, 123)
    verifyScalar("sys::Int",      Str<|Int -123|>, -123)
    verifyScalar("sys::Duration", Str<|Duration "123sec"|>, 123sec)
    verifyScalar("sys::Number",   Str<|Number "123kW"|>, n(123, "kW"))
    verifyScalar("sys::Number",   Str<|Number 123kW|>, n(123, "kW"))
    verifyScalar("sys::Number",   Str<|Number -89m/s|>, n(-89, "m/s"))
    verifyScalar("sys::Number",   Str<|Number 100$|>, n(100, "\$"))
    verifyScalar("sys::Number",   Str<|Number 50%|>, n(50, "%"))
    verifyScalar("sys::Date",     Str<|Date "2023-02-24"|>, Date("2023-02-24"))
    verifyScalar("sys::Date",     Str<|Date 2023-03-04|>, Date("2023-03-04"))
    verifyScalar("sys::Time",     Str<|Time "02:30:00"|>, Time("02:30:00"))
    verifyScalar("sys::Time",     Str<|Time 02:30:00|>, Time("02:30:00"))
    verifyScalar("sys::Ref",      Str<|Ref "abc"|>, Ref("abc"))
    verifyScalar("sys::Version",  Str<|Version "1.2.3"|>, Version("1.2.3"))
    verifyScalar("sys::Version",  Str<|sys::Version "1.2.3"|>, Version("1.2.3"))
    verifyScalar("sys::Uri",      Str<|Uri "file.txt"|>, `file.txt`)
    verifyScalar("sys::DateTime", Str<|DateTime "2023-02-24T10:51:47.21-05:00 New_York"|>, DateTime("2023-02-24T10:51:47.21-05:00 New_York"))
    verifyScalar("sys::DateTime", Str<|DateTime "2023-03-04T12:26:41.495Z"|>, DateTime("2023-03-04T12:26:41.495Z UTC"))
    verifyScalar("sys::DateTime", Str<|DateTime 2023-03-04T12:26:41.495Z|>, DateTime("2023-03-04T12:26:41.495Z UTC"))

    // whitespace
    verifyScalar("sys::Date",
         Str<|Date
                 "2023-03-04"
              |>, Date("2023-03-04"))
    verifyScalar("sys::Date",
         Str<|Date


              2023-03-04
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
      if (src[sp+1] == '"' || src[-1] == '"')
      {
        str := src[sp+2..-2]
        regex := Regex(pattern)
        verifyEq(regex.matches(str), true)
      }
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

//////////////////////////////////////////////////////////////////////////
// Inherit
//////////////////////////////////////////////////////////////////////////

  Void testInheritSlots()
  {
    lib := compileLib(
      Str<|A: {
             foo: Number <a> 123  // a-doc
           }

           B: A

           C: A {
             foo: Int <c>
           }

           D: A {
             foo: Number 456 // d-doc
           }
           |>)

    //env.print(lib)

    num := env.type("sys::Number")
    int := env.type("sys::Int")

    a := lib.slot("A"); af := a.slot("foo")
    b := lib.slot("B"); bf := b.slot("foo")
    c := lib.slot("C"); cf := c.slot("foo")
    d := lib.slot("D"); df := d.slot("foo")

    verifyInheritSlot(a, af, num, num, ["a":m, "val":n(123), "doc":"a-doc"], "a,val,doc")
    verifySame(bf, af)
    verifyInheritSlot(c, cf, af, int, ["a":m, "val":n(123), "doc":"a-doc", "c":m], "c")
    verifyInheritSlot(d, df, af, num, ["a":m, "val":n(456), "doc":"d-doc"], "val,doc")
  }

  Void verifyInheritSlot(DataType parent, DataSpec s, DataSpec base, DataType type, Str:Obj meta, Str ownNames)
  {
    // echo("-- testInheritSlot $s base:$s.base type:$s.type")
    // s.each |v, n| { echo("  $n: $v [$v.typeof] " + (s.own.has(n) ? "own" : "inherit")) }

    verifySame(s.parent, parent)
    verifyEq(s.qname, parent.qname + "." + s.name)
    verifySame(s.base, base)
    verifySame(s.type, type)

    own := ownNames.split(',')
    meta.each |v, n|
    {
      verifyEq(s[n], v)
      verifyEq(s.trap(n), v)
      verifyEq(s.has(n), true)
      verifyEq(s.missing(n), false)

      isOwn := own.contains(n)
      verifyEq(s.own[n], isOwn ? v : null)
      verifyEq(s.own.has(n), isOwn)
      verifyEq(s.own.missing(n), !isOwn)
    }

    s.each |v, n|
    {
      verifyEq(meta[n], v, n)
    }
  }

}