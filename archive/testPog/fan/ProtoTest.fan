//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jan 2023  Brian Frank  Creation
//

using pog

**
** ProtoTest
**
class ProtoTest : AbstractPogTest
{

//////////////////////////////////////////////////////////////////////////
// Lib Errs
//////////////////////////////////////////////////////////////////////////

  Void testLibErrs()
  {
    src :=
    Str<|bad: {}
         |>
    env := PogEnv.cur
    events := compileLibErrs(src, "sys", "test.BadName")
    // echo(events.join("\n"))
    verifyEq(events.size, 2)
    verifyEq(events[0].msg, "Invalid qname for lib, each name must be start with lower case")
    verifyEq(events[1].msg, "Invalid name for lib child - must be capitalized type name")
  }

//////////////////////////////////////////////////////////////////////////
// Gets
//////////////////////////////////////////////////////////////////////////

  Void testGets()
  {
    src :=
    Str<|Foo: {
           a: Str "Foo a"
           b: Str "Foo b"
           c: Str "Foo c"
         }
         Bar: Foo {
           b: Str "Bar b"
           c: Str "Bar c"
         }
         Baz: Bar {
           c: Str "Baz c"
         }
         |>
    sys := env.load("sys")
    lib := compileLib(src, "sys", "test.gets")

    // sanity check sys
    verifyGet(sys,      "Obj",     "sys.Obj",         null)
    verifyGet(sys->Obj, "_sealed", "sys.Obj._sealed", "marker")
    verifyGet(sys,       "Date",   "sys.Date",        "2000-01-01")

    // get/has/missing and getOwn/hasOwn/missingOwn
    verifyGet(lib,      "Foo", "test.gets.Foo",   null)
    verifyGet(lib->Foo, "a",   "test.gets.Foo.a", "Foo a")
    verifyGet(lib->Foo, "b",   "test.gets.Foo.b", "Foo b")
    verifyGet(lib->Foo, "c",   "test.gets.Foo.c", "Foo c")
    verifyGet(lib->Bar, "a",   "test.gets.Foo.a", "Foo a", null, null)
    verifyGet(lib->Bar, "b",   "test.gets.Bar.b", "Bar b")
    verifyGet(lib->Bar, "c",   "test.gets.Bar.c", "Bar c")
    verifyGet(lib->Baz, "a",   "test.gets.Foo.a", "Foo a", null, null)
    verifyGet(lib->Baz, "b",   "test.gets.Bar.b", "Bar b", null, null)
    verifyGet(lib->Baz, "c",   "test.gets.Baz.c", "Baz c")

    // getq
    verifySame(lib.getq(QName("")),      lib)
    verifySame(lib.getq(QName("Foo")),   lib->Foo)
    verifySame(lib.getq(QName("Foo.a")), lib->Foo->a)
    verifyEq(lib.getq(QName("Foo.bad"), false), null)
    verifyErr(UnknownProtoErr#) { lib.getq(QName("Foo.bad")) }
    verifyErr(UnknownProtoErr#) { lib.getq(QName("Foo.bad"), true) }
  }

  Void verifyGet(Proto p, Str n, Str? qname, Str? val, Str? qnameOwn := qname, Str? valOwn := val)
  {
    // echo(">> $p | $n | " + p.get(n, false) + " | "+ p.getOwn(n, false))

    // effective
    if (qname == null)
    {
      verifyEq(p.has(n), false)
      verifyEq(p.missing(n), true)
      verifyEq(p.get(n, false), null)
      verifyEq(p.getq(QName(n), false), null)
      verifyErr(UnknownProtoErr#) { p.get(n) }
      verifyErr(UnknownProtoErr#) { p.get(n, true) }
      verifyErr(UnknownProtoErr#) { p.getq(QName(n)) }
      verifyErr(UnknownProtoErr#) { p.getq(QName(n), true) }
    }
    else
    {
      x := p.get(n)

      verifyEq(x.qname.toStr, qname)
      verifyEq(x.val(false), val)

      verifyEq(p.has(n), true)
      verifyEq(p.missing(n), false)
      verifySame(p.getq(QName(n)), x)
    }

    // own
    if (qnameOwn == null)
    {
      verifyEq(p.hasOwn(n), false)
      verifyEq(p.missingOwn(n), true)
      verifyEq(p.getOwn(n, false), null)
      verifyErr(UnknownProtoErr#) { p.getOwn(n) }
      verifyErr(UnknownProtoErr#) { p.getOwn(n, true) }
    }
    else
    {
      x := p.getOwn(n)

      verifyEq(x.qname.toStr, qname)
      verifyEq(x.val(false), val)

      verifyEq(p.hasOwn(n), true)
      verifyEq(p.missingOwn(n), false)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fits
//////////////////////////////////////////////////////////////////////////

  Void testFits()
  {
    src :=
    Str<|A: { a }
         B: { b }
         AX: A {}
         BX: B {}
         Data: {
           a: A
           b: B
           ax: AX
           bx: BX
         }
         |>

    sys := env.load("sys")
    lib := compileLib(src, "sys", "test")

    a := lib->A
    b := lib->B
    ax := lib->AX
    bx := lib->BX

    verifyFits(a, sys->Obj,  true)
    verifyFits(a, sys->Dict, true)
    // TODO should we check the name ordinal rules?
    //verifyFits(a, sys->List, false)
    verifyFits(a, a, true)
    verifyFits(a, b, false)
    verifyFits(ax, a, true)
    verifyFits(ax, b, false)
    verifyFits(ax, ax, true)
  }

  Void verifyFits(Proto x, Proto type, Bool expect)
  {
    // echo("~~ fits $x | $type")
    actual := x.fits(type)
    verifyEq(actual, expect, x.qname.toStr)
  }

}