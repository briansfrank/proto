//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 2022  Brian Frank  Creation
//

using proto

**
** Compile tests
**
class CompileTest : AbstractCompileTest
{

//////////////////////////////////////////////////////////////////////////
// Basics
//////////////////////////////////////////////////////////////////////////

  Void testBasics()
  {
    // just sys
    compile(["sys"])
    verifyEq(ps.libs.size, 1)
    verifySame(ps.libs[0], ps.lib("sys"))
    verifySys(ps)

    // sys + ph
    compile(["sys", "ph"])
    verifyEq(ps.libs.size, 2)
    verifySame(ps.libs[0], ps.lib("ph"))
    verifySame(ps.libs[1], ps.lib("sys"))
    verifySys(ps)
    verifyPh(ps)

    // now test JSON
/* TODO
    sb := StrBuf()
    ps.encodeJson(sb.out)
    json := sb.toStr
    ps = ProtoEnv.cur.decodeJson(json.in)
    verifyEq(ps.libs.size, 2)
    verifySame(ps.libs[0], ps.lib("ph"))
    verifySame(ps.libs[1], ps.lib("sys"))
    verifySys(ps)
    verifyPh(ps)
*/
  }

  private Void verifySys(ProtoSpace ps)
  {
    sys := verifyLib(ps, "sys", "0.9.1")
    verifySame(ps.root->sys, sys)

    obj    := verifyProto("sys.Obj",    null,   null)
    marker := verifyProto("sys.Marker", obj,    null)
    val    := verifyProto("sys.Val",    obj,    null)
    scalar := verifyProto("sys.Scalar", val,    null)
    bool   := verifyProto("sys.Bool",   scalar, null)
    boolT  := verifyProto("sys.True",   bool,   "true")
    boolF  := verifyProto("sys.False",  bool,   "false")
    str    := verifyProto("sys.Str",    scalar, null)

    objDoc    := verifyProto("sys.Obj._doc", str, "Root type for all objects")
    objDocDoc := verifyProto("sys.Obj._doc._doc", str, "Documentation for object")
    valDoc    := verifyProto("sys.Val._doc", objDoc, "Data value type")
    scalarDoc := verifyProto("sys.Scalar._doc", objDoc, "Scalar is an atomic value kind")

    verifySame(sys->Obj, obj)
    verifySame(obj->_doc, objDoc)
    verifyErr(UnknownProtoErr#) { sys->Foo }
    verifyErr(UnknownProtoErr#) { obj->foo }
  }

  private Void verifyPh(ProtoSpace ps)
  {
    ph := verifyLib(ps, "ph", "3.9.12")
    verifySame(ps.root->ph, ph)

    sys := ps.root->sys

    na     := verifyProto("ph.Na",     sys->Obj)
    remove := verifyProto("ph.Remove", sys->Obj)
    ref    := verifyProto("ph.Ref",    sys->Scalar)
    grid   := verifyProto("ph.Grid",   sys->Collection)
    entity := verifyProto("ph.Entity", sys->Dict)
    id     := verifyProto("ph.Entity.id._of", ph->Tag->id)
    str    := verifyProto("ph.Entity.dis._of", ph->Tag->dis)

    depends := verifyProto("ph._depends", sys->Lib->_depends)
    verifyProto("ph._depends._0", sys->Depend)
    verifyProto("ph._depends._0.lib", sys->Depend->lib, "sys")
  }

//////////////////////////////////////////////////////////////////////////
// Syntax
//////////////////////////////////////////////////////////////////////////

  Void testSyntax()
  {
    // try various different empty <> and {}
    compileSrc(
    Str<|A : <>
         B : {}
         C : <> {}
         D :
         <>
         {}

         E :
         <
         >
         {
         }

         F :

         <


         >

         {


         }
         |>)
    verifySyntax1

    // try various meta slots
    compileSrc(
    Str<|A : <foo:"x",bar:"y",baz,>
         B : < foo:"x",  bar:"y" ,  baz >
         C : <
           foo:"x"
           bar:"y"
           baz
           >
         D : <

           foo:"x",

           bar:"y" ,

           baz,

           >
        |>)
    verifySyntax2

    // try various data slots
    compileSrc(
    Str<|A : {foo:"x",bar:"y",baz,}
         B : { foo  :  "x"  ,  bar : "y" ,   baz }
         C : {
           foo:"x"
           bar:"y"
           baz
           }
         D : {

           foo:"x",

           bar:"y" ,

           baz,

           }
        |>)
    verifySyntax3
  }

  private Void verifySyntax1()
  {
    ps.lib("test").eachOwn |x|
    {
      if (x.name[0] == '_') return // TODO
      verifySame(x.type, ps.dict)
    }
  }

  private Void verifySyntax2()
  {
    ps.lib("test").eachOwn |x|
    {
      if (x.name[0] == '_') return // TODO
      verifyEq(x.get("_foo").val, "x")
      verifyEq(x.get("_bar").val, "y")
      verifySame(x.get("_baz").type, ps.marker)
    }
  }

  private Void verifySyntax3()
  {
    //ps.lib("test").dump
    ps.lib("test").eachOwn |x|
    {
      if (x.name[0] == '_') return // TODO
      verifyEq(x.get("foo").val, "x")
      verifyEq(x.get("bar").val, "y")
      verifySame(x.get("baz").type, ps.marker)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Maybe
//////////////////////////////////////////////////////////////////////////

  Void testMaybe()
  {
    test := compileSrc(
     Str<|A : Dict
          B : A?
          C : {
           a: A?
           s: Str? "foo"
           d: Dict? {foo, bar}
          }|>)

    verifyMaybe(test->B,    "test.A")
    verifyMaybe(test->C->a, "test.A")
    verifyMaybe(test->C->s, "sys.Str", "foo")
    verifyMaybe(test->C->d, "sys.Dict", null, "foo,bar")
  }

  Void verifyMaybe(Proto p, Str type, Str? val := null, Str? kids := null)
  {
    verifyEq(p.type.qname, "sys.Maybe")
    verifySame(p.type, ps.root->sys->Maybe)
    of := p->_of
    verifyEq(of.type.qname, type)

    if (val == null) verifyEq(of.hasVal, false)
    else verifyEq(of.val, val)

    if (kids == null) verifyEq(of.listOwn.size, 0)
    else verifyEq(of.listOwn.join(","), kids)
  }

//////////////////////////////////////////////////////////////////////////
// Or/And
//////////////////////////////////////////////////////////////////////////

  Void testAnd() { doCompound("sys.And", "&") }

  Void testOr() { doCompound("sys.Or", "|") }

  Void doCompound(Str type, Str symbol)
  {
    src :=
     Str<|A : {}
          B : {}
          C : {}
          D : {}

          U1 : A|B
          U2 : A  |  B  |  C
          U3 : A  |  B  |  C | D
          U4 : A |
               B |
               C
          U5 : "a" | "b" | "c"
          U6 : A "a" | B "b" | C "c"
          U7 : A {x} | B {y} | C <z>
          U8 : A? | B? {y} | C? <z>
          |>
          .replace("|", symbol)

    compileSrc(src)

     verifyCompound(type, "U1", "A | B")
     verifyCompound(type, "U2", "A | B | C")
     verifyCompound(type, "U3", "A | B | C | D")
     verifyCompound(type, "U4", "A | B | C")
     verifyCompound(type, "U5", "Str a | Str b | Str c")
     verifyCompound(type, "U6", "A a | B b | C c")
     verifyCompound(type, "U7", "A | B | C")
     verifyCompound(type, "U8", "A? | B? | C?")
  }

  Void verifyCompound(Str type, Str name, Str pattern)
  {
    u := ps.root->test.trap(name)
    verifySame(u.type, ps.get(type))
    of := u->_of
    verifyEq(of.qname, "test.${name}._of")
    actual := StrBuf()
    of.eachOwn |x|
    {
      s := x.type.name
      if (s == "Maybe") s = x->_of.type.name + "?"
      if (x.val(false) != null) s += " " + x.val
      actual.join(s, " | ")
    }
    verifyEq(actual.toStr, pattern)
  }

//////////////////////////////////////////////////////////////////////////
// Or/And/Maybe combination
//////////////////////////////////////////////////////////////////////////

  Void testCombo()
  {
    test := compileSrc(
    Str<|A : Dict
         B : Dict
         C : Dict
         D : Dict
         T1 : A | B
         T2 : A | B | C
         T3 : A | B & C
         T4 : A & B | C
         T5 : A & B | C & D
         T6 : A | B & C | D
         T7 : A | B | C & D
         T8 : A|B|C&D
         T9 : A? | B? & C | D
         |>)

    verifyCombo(test->T1, Obj["|", "A", "B"])
    verifyCombo(test->T2, Obj["|", "A", "B", "C"])
    verifyCombo(test->T3, Obj["|", "A", ["&", "B", "C"]])
    verifyCombo(test->T4, Obj["|", ["&", "A", "B"], "C"])
    verifyCombo(test->T5, Obj["|", ["&", "A", "B"], ["&", "C", "D"]])
    verifyCombo(test->T6, Obj["|", "A", ["&", "B", "C"], "D"])
    verifyCombo(test->T7, Obj["|", "A", "B", ["&", "C", "D"]])
    verifyCombo(test->T8, Obj["|", "A", "B", ["&", "C", "D"]])
    verifyCombo(test->T9, Obj["|", "A?", ["&", "B?", "C"], "D"])
  }

  Void verifyCombo(Proto p, Obj[] expected)
  {
    actual := doCombo(p)
    verifyEq(actual.toStr, expected.toStr)
  }

  Obj doCombo(Proto p)
  {
    if (p.type.qname == "sys.And")
      return Obj["&"].addAll(p->_of.listOwn.map { doCombo(it) })

    if (p.type.qname == "sys.Or")
      return Obj["|"].addAll(p->_of.listOwn.map { doCombo(it) })

    if (p.type.qname == "sys.Maybe")
      return p->_of.type.name + "?"

    return p.type.name
  }

//////////////////////////////////////////////////////////////////////////
// Unnamed
//////////////////////////////////////////////////////////////////////////

  Void testUnnamed()
  {
    test := compileSrc(
    Str<|Box : Dict {}

         A : {
           a:Box {}
           b:Box, c:Box
         }

         B : {
           Box {}
           Box, Box
         }
         |>)

    b := test->B
    kids := Proto[,]
    b.eachOwn |x| { kids.add(x) }
    verifyEq(kids.size, 3)
    kids.each |kid| { verifyEq(kid.type.qname, "test.Box") }
  }

//////////////////////////////////////////////////////////////////////////
// NestedSets
//////////////////////////////////////////////////////////////////////////

  Void testNestedSets()
  {
    test := compileSrc(
     Str<|Ahu : {
            discharge: Duct
          }

          Duct : {
            dis: Str
            fan: Fan
            temp: Temp
          }

          Fan : {
            dis: Str
          }

          Temp : {
            dis: Str
          }

          ahu1 : Ahu {
            discharge : {
              dis:"ahu1-discharge",
              fan: { dis:"ahu1-discharge-fan" }
              temp: { dis:"ahu1-discharge-temp" }
            }
          }

          ahu2 : Ahu {
            discharge.dis: "ahu2-discharge"
            discharge.fan.dis: "ahu2-discharge-fan"
            discharge.temp.dis: "ahu2-discharge-temp"
          }

         |>)

    verifyNestedSet(test->ahu1, "ahu1")
    verifyNestedSet(test->ahu2, "ahu2")
  }

  Void verifyNestedSet(Proto p, Str dis)
  {
    verifyEq(p.type.qname, "test.Ahu")

    d := p->discharge
    verifyEq(d->dis.val, "$dis-discharge")
    verifyEq(d.type.qname, "test.Ahu.discharge")

    df := d->fan
    verifyEq(df->dis.val, "$dis-discharge-fan")
    //verifyEq(df.type.qname, "test.Fan")  TODO need type inference here

    dt := d->temp
    verifyEq(dt->dis.val, "$dis-discharge-temp")
  }

//////////////////////////////////////////////////////////////////////////
// Inherited Bindings
//////////////////////////////////////////////////////////////////////////

  Void testInheritBinding()
  {
    x := compileSrc(
    Str<|foo2 : Foo  { something: "else" }
         bar2 : { bind:test.foo2.a }

         Foo : {
           a: Str
         }

         SubFoo : Foo

         foo1 : Foo
         foo3 : SubFoo

         bar0 : { bind:test.Foo.a }
         bar1 : { bind:test.foo1.a }
         bar3 : { bind:test.foo3.a }
         |>)

    //x.dump

    verifyEq(x->bar0->bind.type.qname, "test.Foo.a")
    verifyEq(x->bar1->bind.type.qname, "test.foo1.a")
    verifyEq(x->bar2->bind.type.qname, "test.foo2.a")
    verifyEq(x->bar3->bind.type.qname, "test.foo3.a")

    verifyEq(x->foo1.getOwn("a").qname, "test.foo1.a")
    verifyEq(x->foo2.getOwn("a").qname, "test.foo2.a")
    verifyEq(x->foo3.getOwn("a").qname, "test.foo3.a")

    verifySame(x->foo1.getOwn("a").type, ps.get("test.Foo.a"))
    verifySame(x->foo2.getOwn("a").type, ps.get("test.Foo.a"))
    verifySame(x->foo3.getOwn("a").type, ps.get("test.Foo.a"))
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private ProtoLib verifyLib(ProtoSpace ps, Str qname, Str version)
  {
    lib := ps.lib(qname)
    verifySame(lib, ps.get(qname))
    verifyProto(qname, ps.sys->Lib, null)
    verifyProto(qname+"._version", ps.sys->Lib->_version, version)
    verifyEq(lib.version, Version(version))
    return lib
  }

  private Proto verifyProto(Str path, Proto? type, Obj? val := null)
  {
    p := get(path)
    // echo("$p.loc [$p.qname]")
    verifyEq(p.name, path.split('.').last)
    verifyEq(p.qname, path)
    verifySame(p.type, type)
    verifyEq(p.toStr, path)
    if (val != null)
    {
      verifyEq(p.val, val)
    }
    else
    {
      verifyEq(p.val(false), null)
      verifyErr(ProtoMissingValErr#) { p.val }
      verifyErr(ProtoMissingValErr#) { p.val(true) }
    }
    return p
  }
}

