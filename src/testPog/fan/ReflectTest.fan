//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using pog

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

    a := getq("test.Alpha")
    b := getq("test.Bravo")
    c := getq("test.Charlie")
    d := getq("test.Delta")

    verifyInherit(a, "a,b,c", ["Alpha.a", "Alpha.b", "Alpha.c"])
    verifyInherit(b, "b,c",   ["Alpha.a", "Bravo.b", "Bravo.c"])
    verifyInherit(c, "c",     ["Alpha.a", "Bravo.b", "Charlie.c"])
    verifyInherit(d, "a,b",   ["Delta.a", "Delta.b", "Charlie.c"])
  }

  private Void verifyInherit(Proto p, Str own, Str[] slots)
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
    myScalar := graph.getq("test.MyScalar")
    verifyEq(p->a.fits(myScalar), true, "a: " + p->a.type)
    verifyEq(p->b.fits(myScalar), true, "b: " + p->b.type)
    verifyEq(p->c.fits(myScalar), true, "c: " + p->c.type)

    // get as method
    verifyEq(p.get("a").val, "av")
    verifyEq(p.get("b").val, "bv")
    verifyEq(p.get("c").val, "cv")

    // get path of each slot
    verifyEq(p.get("a").qname.toStr, "test." + slots[0])
    verifyEq(p.get("b").qname.toStr, "test." + slots[1])
    verifyEq(p.get("c").qname.toStr, "test." + slots[2])

    // each
    map := Str:Str[:] { ordered = true }
    p.each |kid|
    {
      if (kid.qname.toStr.startsWith("sys.")) return
      map[kid.name] = kid.val
    }
    verifyEq(map, ["a":"av", "b":"bv", "c":"cv"])

    // each - with own check
    map.clear
    p.each |kid|
    {
      if (kid.qname.toStr.startsWith("sys.")) return
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
    verifyEq(map.keys.join(","), own)

    // eachOwn
    map.clear
    p.eachOwn |kid|
    {
      if (kid.qname.toStr.startsWith("sys.")) return
      map[kid.name] = kid.val
    }
    verifyEq(map.keys.join(","), own)

    // eachOwnWhile
    map.clear
    result := p.eachOwnWhile |kid|
    {
      if (kid.qname.toStr.startsWith("sys.")) return null
      map[kid.name] = kid.val
      return kid.name == "b" ? "break" : null
    }
    verifyEq(result, own.contains("b") ? "break" : null)
    verifyEq(map.keys.join(","), own.contains("b") ? own[0..own.index("b")] : own)

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
    Str<|AlphaX: {}
         BetaX: {}
         BetaFoo: {}
         BetaY : BetaFoo & BetaX {}

         Alpha : AlphaX {
           a: "alpha.a"
           b: "alpha.b"
           c: "alpha.c"
         }

         Beta : BetaY {
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

    sys := graph.lib("sys")

    // simple single inheritance
    verifyFits(test->A2, sys->And,      false)
    verifyFits(test->A2, test->A2,      true)
    verifyFits(test->A2, test->Alpha,   true)
    verifyFits(test->A2, test->AlphaX,  true)
    verifyFits(test->A2, test->Beta,    false)
    verifyFits(test->A2, test->BetaX,   false)
    verifyFits(test->A2, test->Charlie, false)
    verifyFits(test->A2, test->AB,      false)
    verifyFits(test->A2, test->ABC,     false)
    verifyChildren(test->A2, [
      ["test.Alpha.a", "alpha.a", "sys.Str"],
      ["test.Alpha.b", "alpha.b", "sys.Str"],
      ["test.Alpha.c", "alpha.c", "sys.Str"],
      ])

    // double inheritance
    verifyFits(test->AB, sys->And,      true)
    verifyFits(test->AB, test->AB,      true)
    verifyFits(test->AB, test->Alpha,   true)
    verifyFits(test->AB, test->AlphaX,  true)
    verifyFits(test->AB, test->Beta,    true)
    verifyFits(test->AB, test->BetaX,   true)
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
    verifyFits(test->BA, test->AlphaX,  true)
    verifyFits(test->BA, test->Beta,    true)
    verifyFits(test->BA, test->BetaX,   true)
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
    verifyFits(test->ABC, test->AlphaX,  true)
    verifyFits(test->ABC, test->Beta,    true)
    verifyFits(test->ABC, test->BetaX,   true)
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
    verifyFits(test->CBA, test->BetaX,   true)
    verifyFits(test->CBA, test->Alpha,   true)
    verifyFits(test->CBA, test->AlphaX,  true)
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
    verifyFits(test->ABX, test->AlphaX,  true)
    verifyFits(test->ABX, test->Beta,    true)
    verifyFits(test->ABX, test->BetaX,   true)
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
// Or
//////////////////////////////////////////////////////////////////////////

  Void testOr()
  {
    test := compileSrc(
    Str<|A: {a1:"A.a1", a2:"A.a2"}
         B: {b1:"b1",   b2:"B.b2"}
         C: {c1:"c1",   c2:"C.c2"}

         X: {x1:"X.x1"}
         Z: {z1:"Z.z1"}
         AX: A & X
         BX: B & X
         AY: AX { y1:"AY.y1" }
         BY: BX { y1:"BY.y1" }
         AZ: Z & AY
         BZ: BY & Z

         AB : A | B
         AXBX: AX | BX
         AYBY: AY | BY
         AZBZ: AZ | BZ

         AZBZ_More: AZ | BZ <foo> { a1: "More.a1" }
         |>)

    sys := graph.lib("sys")

    // A | B
    cur := test->AB
    verifyFits(cur, sys->Or,  true)
    verifyFits(cur, test->AB, true)
    verifyFits(cur, test->A,  false)
    verifyFits(cur, test->B,  false)
    verifyFits(cur, test->C,  false)
    verifyFits(cur, test->AX, false)
    verifyFits(cur, test->BX, false)
    verifySame(cur.get("a1", false), null)
    verifySame(cur.get("b1", false), null)
    verifyChildren(cur, [
      ,
      ])

    // AX | BX
    cur = test->AXBX
    verifyFits(cur, sys->Or,    true)
    verifyFits(cur, test->AXBX, true)
    verifyFits(cur, test->A,    false)
    verifyFits(cur, test->B,    false)
    verifyFits(cur, test->X,    true)
    verifyFits(cur, test->AX,   false)
    verifyFits(cur, test->BX,   false)
    verifySame(cur.get("a1", false), null)
    verifySame(cur.get("b1", false), null)
    verifySame(cur.get("x1", false), test->X->x1)
    verifyChildren(cur, [
      ["test.X.x1",  "X.x1",  "sys.Str"],
      ])

    // AY | BY
    cur = test->AYBY
    verifyFits(cur, sys->Or,    true)
    verifyFits(cur, test->AYBY, true)
    verifyFits(cur, test->AXBX, false)
    verifyFits(cur, test->A,    false)
    verifyFits(cur, test->B,    false)
    verifyFits(cur, test->X,    true)
    verifyFits(cur, test->AX,   false)
    verifyFits(cur, test->BX,   false)
    verifySame(cur.get("a1", false), null)
    verifySame(cur.get("b1", false), null)
    verifySame(cur.get("x1", false), test->X->x1)
    verifyChildren(cur, [
      ["test.X.x1",  "X.x1",  "sys.Str"],
      ])

    // AZ | BZ
    cur = test->AZBZ
    verifyFits(cur, sys->Or,    true)
    verifyFits(cur, test->AZBZ, true)
    verifyFits(cur, test->AYBY, false)
    verifyFits(cur, test->AXBX, false)
    verifyFits(cur, test->A,    false)
    verifyFits(cur, test->B,    false)
    verifyFits(cur, test->X,    true)
    verifyFits(cur, test->Z,    true)
    verifyFits(cur, test->AX,   false)
    verifyFits(cur, test->BX,   false)
    verifySame(cur.get("a1", false), null)
    verifySame(cur.get("b1", false), null)
    verifySame(cur.get("x1", false), test->X->x1)
    verifySame(cur.get("z1", false), test->Z->z1)
    verifyChildren(cur, [
      ["test.Z.z1",  "Z.z1",  "sys.Str"],
      ["test.X.x1",  "X.x1",  "sys.Str"],
      ])

    // AZ | BZ with meta + children
    cur = test->AZBZ_More
    verifyFits(cur, sys->Or,    true)
    verifyFits(cur, test->AZBZ_More, true)
    verifyFits(cur, test->AZBZ, false)
    verifyFits(cur, test->AYBY, false)
    verifyFits(cur, test->AXBX, false)
    verifyFits(cur, test->A,    false)
    verifyFits(cur, test->B,    false)
    verifyFits(cur, test->X,    true)
    verifyFits(cur, test->Z,    true)
    verifyFits(cur, test->AX,   false)
    verifyFits(cur, test->BX,   false)
    verifySame(cur.get("a1", false), cur->a1)
    verifySame(cur.get("b1", false), null)
    verifySame(cur.get("x1", false), test->X->x1)
    verifySame(cur.get("z1", false), test->Z->z1)
    verifyChildren(cur, [
      ["test.AZBZ_More._foo", null,      "sys.Marker"],
      ["test.AZBZ_More.a1",   "More.a1", "test.A.a1"],
      ["test.Z.z1",           "Z.z1",    "sys.Str"],
      ["test.X.x1",           "X.x1",    "sys.Str"],
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
      if (kid.name == "_of" || kid.qname.toStr.startsWith("sys.")) return
      e := expected[i++]
      // echo(" >> $kid [$kid.type] ?= $e")
      verifyEq(kid.qname.toStr,      e[0])
      verifyEq(kid.val(false),       e[1])
      verifyEq(kid.type.qname.toStr, e[2])
      verifyEq(p.has(kid.name),      true)
      verifySame(p.get(kid.name),    kid)
    }
    verifyEq(i, expected.size)
  }

}

