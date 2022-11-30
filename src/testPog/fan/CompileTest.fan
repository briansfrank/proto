//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 2022  Brian Frank  Creation
//

using pog

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
    verifyEq(graph.libs.size, 1)
    verifySame(graph.libs[0], graph.lib("sys"))
    verifySys

    // sys + ph
    compile(["sys", "ph"])
    verifyEq(graph.libs.size, 2)
    verifySame(graph.libs[0], graph.lib("ph"))
    verifySame(graph.libs[1], graph.lib("sys"))
    verifySys
    verifyPh
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
    graph.lib("test").eachOwn |x|
    {
      if (x.name[0] == '_') return // TODO
      verifySame(x.type, graph->sys->Dict)
    }
  }

  private Void verifySyntax2()
  {
    graph.lib("test").eachOwn |x|
    {
      if (x.name[0] == '_') return // TODO
      verifyEq(x.get("_foo").val, "x")
      verifyEq(x.get("_bar").val, "y")
      verifySame(x.get("_baz").type, graph->sys->Marker)
    }
  }

  private Void verifySyntax3()
  {
    //graph.lib("test").dump
    graph.lib("test").eachOwn |x|
    {
      if (x.name[0] == '_') return // TODO
      verifyEq(x.get("foo").val, "x")
      verifyEq(x.get("bar").val, "y")
      verifySame(x.get("baz").type, graph->sys->Marker)
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
    verifySame(p.type, graph->sys->Maybe)
    of := p->_of
    verifyEq(of.type.qname, type)

    if (val == null) verifyEq(p.hasVal, false)
    else verifyEq(p.val, val)

    list := p.listOwn.findAll { it.name != "_of" }
    if (kids == null) verifyEq(list.size, 0)
    else verifyEq(list.join(",") { it.name }, kids)
  }

//////////////////////////////////////////////////////////////////////////
// Or/And
//////////////////////////////////////////////////////////////////////////

  Str srcForOr()
  {
     Str<|A : {}
          B : {}
          C : {}
          D : {}

          X1 : A|B
          X2 : A  |  B  |  C
          X3 : A  |  B  |  C | D
          X4 : A |
               B |
               C
          X5 : test.A  |  test.B  |  test.C | test.D
          X6 : "a" | "b" | "c"
          X7 : Str "a" | sys.Str "b" | Str  "c"
          X8 : A "a" | B "b" | C  "c"
          X9 : test.A "a" | test.B "b" | test.C  "c"
          X10 : "a" |
               "b" |
               "c"
          X11 : test.A "a" |
               "b" |
               C "c"
          |>
  }

  Str srcForAnd()
  {
    srcForOr[0 ..< srcForOr.index("X6")].replace("|", "&")
  }

  Void testOr()
  {
    test := compileSrc(srcForOr)
    type := "sys.Or"
    verifyCompound(type, "X1", "A | B")
    verifyCompound(type, "X2", "A | B | C")
    verifyCompound(type, "X3", "A | B | C | D")
    verifyCompound(type, "X4", "A | B | C")
    verifyCompound(type, "X5", "A | B | C | D")
    verifyCompound(type, "X6", "Str a | Str b | Str c")
    verifyCompound(type, "X7", "Str a | Str b | Str c")
    verifyCompound(type, "X8", "A a | B b | C c")
    verifyCompound(type, "X9", "A a | B b | C c")
    verifyCompound(type, "X10", "Str a | Str b | Str c")
    verifyCompound(type, "X11", "A a | Str b | C c")
  }

  Void testAnd()
  {
    test := compileSrc(srcForAnd)
    type := "sys.And"
    verifyCompound(type, "X1", "A | B")
    verifyCompound(type, "X2", "A | B | C")
    verifyCompound(type, "X3", "A | B | C | D")
    verifyCompound(type, "X4", "A | B | C")
    verifyCompound(type, "X5", "A | B | C | D")
  }

  Void verifyCompound(Str type, Str name, Str pattern)
  {
    u := graph->test.trap(name)
    verifySame(u.type, graph.getq(type))
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

  /* Current grammar disallows both and/or productions used together
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
  */

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

    verifySame(x->foo1.getOwn("a").type, graph.getq("test.Foo.a"))
    verifySame(x->foo2.getOwn("a").type, graph.getq("test.Foo.a"))
    verifySame(x->foo3.getOwn("a").type, graph.getq("test.Foo.a"))
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////


}

