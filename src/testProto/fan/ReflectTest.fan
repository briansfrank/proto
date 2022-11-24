//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using proto
using protoc

**
** Reflection tests
**
class ReflectTest : AbstractCompileTest
{

//////////////////////////////////////////////////////////////////////////
// Inherit
//////////////////////////////////////////////////////////////////////////

  Void testInherit()
  {
    compileSrc(
    Str<|MyScalar: Scalar

         Alpha : {
           a: MyScalar "av"
           b: MyScalar "bv"
           c: MyScalar "cv"
         }

         Bravo : Alpha {
           b: "bv"
           c: "cv"
         }

         Charlie : Bravo {
           c: "cv"
         }

         Delta : Charlie {
           a: "av"
           b: "bv"
         }
         |>)

    a := get("test.Alpha")
    b := get("test.Bravo")
    c := get("test.Charlie")
    d := get("test.Delta")

    verifyInherit(a, "a,b,c", ["Alpha.a", "Alpha.b", "Alpha.c"])
    verifyInherit(b, "b,c",   ["Alpha.a", "Bravo.b", "Bravo.c"])
    verifyInherit(c, "c",     ["Alpha.a", "Bravo.b", "Charlie.c"])
    verifyInherit(d, "a,b",   ["Delta.a", "Delta.b", "Charlie.c"])
  }

  private Void verifyInherit(Proto p, Str declared, Str[] slots)
  {
   // echo("--- $p "); p.dump

    // has
    verifyEq(p.has("a"), true)
    verifyEq(p.has("b"), true)
    verifyEq(p.has("c"), true)

    // get as operator
    verifyEq(p["a"].val, "av")
    verifyEq(p["b"].val, "bv")
    verifyEq(p["c"].val, "cv")

    // make sure everything subtypes from MyScalar
    myScalar := graph.get("test.MyScalar")
    verifyEq(p->a.fits(myScalar), true, "a: " + p->a.type)
    verifyEq(p->b.fits(myScalar), true, "b: " + p->b.type)
    verifyEq(p->c.fits(myScalar), true, "c: " + p->c.type)

    // get as method
    verifyEq(p.get("a").val, "av")
    verifyEq(p.get("b").val, "bv")
    verifyEq(p.get("c").val, "cv")

    // get path of each slot
    verifyEq(p.get("a").qname, "test." + slots[0])
    verifyEq(p.get("b").qname, "test." + slots[1])
    verifyEq(p.get("c").qname, "test." + slots[2])

    // each
    map := Str:Str[:] { ordered = true }
    p.each |kid|
    {
      if (kid.name.startsWith("_")) return
      map[kid.name] = kid.val
    }
    verifyEq(map, ["a":"av", "b":"bv", "c":"cv"])

    // each - declared only
    map.clear
    p.each |kid|
    {
      if (kid.name.startsWith("_")) return
      if (p.hasOwn(kid.name))
      {
        verifySame(p.get(kid.name), p.getOwn(kid.name))
        map[kid.name] = kid.val
      }
      else
      {
        verifyEq(p.getOwn(kid.name, false), null)
        verifyErr(UnknownProtoErr#) { p.getOwn(kid.name) }
        verifyErr(UnknownProtoErr#) { p.getOwn(kid.name, true) }
      }
    }
    verifyEq(map.keys.join(","), declared)

    // bad
    verifyEq(p.has("bad"), false)
    verifyEq(p.hasOwn("bad"), false)
    verifyEq(p.get("bad", false), null)
    verifyEq(p.getOwn("bad", false), null)
    verifyErr(UnknownProtoErr#) { p.get("bad") }
    verifyErr(UnknownProtoErr#) { p.get("bad", true) }
    verifyErr(UnknownProtoErr#) { p.getOwn("bad") }
    verifyErr(UnknownProtoErr#) { p.getOwn("bad", true) }
  }

//////////////////////////////////////////////////////////////////////////
// And
//////////////////////////////////////////////////////////////////////////

  Void testAnd()
  {
    test := compileSrc(
    Str<|Alpha : {
           a: "alpha.a"
           b: "alpha.b"
           c: "alpha.c"
         }

         Beta : {
           b: "beta.b"
           c: "beta.c"
           d: "beta.d"
         }

         Charlie : {
           c: "charlie.c"
           d: "charlie.d"
           e: "charlie.e"
         }

         A2: Alpha
         AB: Alpha & Beta
         BA: Beta & Alpha
         ABC: A2 & Beta & Charlie
         CBA: Charlie & Beta & Alpha

         ABX: Alpha & Beta {
           b: "abx.b"
           x: "abx.x"
         }

         ABY: Alpha & Beta <foo, bar:"baz">

         ABZ: Alpha & Beta <foo, bar:"baz"> {
           c: "abz.c"
           z: "abz.z"
         }
         |>)

    // simple single inheritance
    verifyFits(test->A2, test->A2,      true)
    verifyFits(test->A2, test->Alpha,   true)
    verifyFits(test->A2, test->Beta,    false)
    verifyFits(test->A2, test->Charlie, false)
    verifyFits(test->A2, test->AB,      false)
    verifyFits(test->A2, test->ABC,     false)
    verifyChildren(test->A2, [
      ["test.Alpha.a", "alpha.a", "sys.Str"],
      ["test.Alpha.b", "alpha.b", "sys.Str"],
      ["test.Alpha.c", "alpha.c", "sys.Str"],
      ])

    // double inheritance
    verifyFits(test->AB, test->AB,      true)
    verifyFits(test->AB, test->Alpha,   true)
    verifyFits(test->AB, test->Beta,    true)
    verifyFits(test->AB, test->Charlie, false)
    verifyFits(test->AB, test->BA,      false)
    verifyFits(test->AB, test->ABC,     false)
    verifyChildren(test->AB, [
      ["test.Alpha.a", "alpha.a", "sys.Str"],
      ["test.Alpha.b", "alpha.b", "sys.Str"],
      ["test.Alpha.c", "alpha.c", "sys.Str"],
      ["test.Beta.d",  "beta.d",  "sys.Str"],
      ])

    // double inheritance - flip order
    verifyFits(test->BA, test->BA,      true)
    verifyFits(test->BA, test->Alpha,   true)
    verifyFits(test->BA, test->Beta,    true)
    verifyFits(test->BA, test->Charlie, false)
    verifyFits(test->BA, test->AB,      false)
    verifyFits(test->BA, test->ABC,     false)
    verifyChildren(test->BA, [
      ["test.Beta.b",  "beta.b", "sys.Str"],
      ["test.Beta.c",  "beta.c", "sys.Str"],
      ["test.Beta.d",  "beta.d",  "sys.Str"],
      ["test.Alpha.a", "alpha.a", "sys.Str"],
      ])

    // triple inheritance
    verifyFits(test->ABC, test->ABC,     true)
    verifyFits(test->ABC, test->Alpha,   true)
    verifyFits(test->ABC, test->Beta,    true)
    verifyFits(test->ABC, test->Charlie, true)
    verifyFits(test->ABC, test->AB,      false)
    verifyFits(test->ABC, test->CBA,     false)
    verifyChildren(test->ABC, [
      ["test.Alpha.a",   "alpha.a",   "sys.Str"],
      ["test.Alpha.b",   "alpha.b",   "sys.Str"],
      ["test.Alpha.c",   "alpha.c",   "sys.Str"],
      ["test.Beta.d",    "beta.d",    "sys.Str"],
      ["test.Charlie.e", "charlie.e", "sys.Str"],
      ])

    // triple inheritance - flip order
    verifyFits(test->CBA, test->CBA,     true)
    verifyFits(test->CBA, test->Charlie, true)
    verifyFits(test->CBA, test->Beta,    true)
    verifyFits(test->CBA, test->Alpha,   true)
    verifyFits(test->CBA, test->AB,      false)
    verifyChildren(test->CBA, [
      ["test.Charlie.c", "charlie.c", "sys.Str"],
      ["test.Charlie.d", "charlie.d", "sys.Str"],
      ["test.Charlie.e", "charlie.e", "sys.Str"],
      ["test.Beta.b",    "beta.b",    "sys.Str"],
      ["test.Alpha.a",   "alpha.a",   "sys.Str"],
      ])

    // double inheritance with overrides
    verifyFits(test->ABX, test->ABX,     true)
    verifyFits(test->ABX, test->Alpha,   true)
    verifyFits(test->ABX, test->Beta,    true)
    verifyFits(test->ABX, test->Charlie, false)
    verifyFits(test->ABX, test->AB,      false)
    verifyFits(test->ABX, test->ABC,     false)
    verifyChildren(test->ABX, [
      ["test.ABX.b", "abx.b",     "test.Alpha.b"],
      ["test.ABX.x", "abx.x",     "sys.Str"],
      ["test.Alpha.a", "alpha.a", "sys.Str"],
      ["test.Alpha.c", "alpha.c", "sys.Str"],
      ["test.Beta.d",  "beta.d",  "sys.Str"],
      ])

    // double inheritance with meta
    verifyChildren(test->ABY, [
      ["test.ABY._foo", null,      "sys.Marker"],
      ["test.ABY._bar", "baz",     "sys.Str"],
      ["test.Alpha.a",  "alpha.a", "sys.Str"],
      ["test.Alpha.b",  "alpha.b", "sys.Str"],
      ["test.Alpha.c",  "alpha.c", "sys.Str"],
      ["test.Beta.d",   "beta.d",  "sys.Str"],
      ])

    // double inheritance with meta and children
    verifyChildren(test->ABZ, [
      ["test.ABZ._foo", null,      "sys.Marker"],
      ["test.ABZ._bar", "baz",     "sys.Str"],
      ["test.ABZ.c",    "abz.c",   "test.Alpha.c"],
      ["test.ABZ.z",    "abz.z",    "sys.Str"],
      ["test.Alpha.a",  "alpha.a", "sys.Str"],
      ["test.Alpha.b",  "alpha.b", "sys.Str"],
      ["test.Beta.d",   "beta.d",  "sys.Str"],
      ])
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Void verifyFits(Proto p, Proto base, Bool expected)
  {
    verifyEq(p.fits(base), expected)
  }

  Void verifyChildren(Proto p, Obj?[][] expected)
  {
    i := 0
    list := p.list
    p.each |kid|
    {
      if (kid.name == "_of" || kid.qname.startsWith("sys.")) return
      e := expected[i++]
      verifyEq(kid.qname,       e[0])
      verifyEq(kid.val(false),  e[1])
      verifyEq(kid.type.qname,  e[2])
      verifyEq(p.has(kid.name), true)
      verifySame(p.get(kid.name), kid)
    }
    verifyEq(i, expected.size)
  }

}

