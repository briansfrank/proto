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
class CompileTest : Test
{

  ProtoSpace? ps

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
    ph := verifyLib(ps, "ph", "0.9.1")
    verifySame(ps.root->ph, ph)

    sys := ps.root->sys

    na     := verifyProto("ph.Na",     sys->Obj)
    remove := verifyProto("ph.Remove", sys->Obj)
    ref    := verifyProto("ph.Ref",    sys->Scalar)
    grid   := verifyProto("ph.Grid",   sys->Collection)
    entity := verifyProto("ph.Entity", sys->Dict)
    id     := verifyProto("ph.Entity.id", ph->Ref)
    str    := verifyProto("ph.Entity.dis", sys->Str)
  }

//////////////////////////////////////////////////////////////////////////
// Inherit
//////////////////////////////////////////////////////////////////////////

  Void testInherit()
  {
    compileSrc(
    Str<|Alpha : {
           a: "av"
           b: "bv"
           c: "cv"
         }

         Beta : Alpha {
           b: "bv"
           c: "cv"
         }

         Charlie : Beta {
           c: "cv"
         }
         |>)

    a := get("test.Alpha")
    b := get("test.Beta")
    c := get("test.Charlie")

    verifyInherit(a, "a,b,c", ["Alpha.a", "Alpha.b", "Alpha.c"])
    verifyInherit(b, "b,c",   ["Alpha.a", "Beta.b",  "Beta.c"])
    verifyInherit(c, "c",     ["Alpha.a", "Beta.b",  "Charlie.c"])
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
// Optional
//////////////////////////////////////////////////////////////////////////

  Void testOptional()
  {
    compileSrc(
     Str<|A : { ctrl: {}, foo?:{}, bar?:"" }
          B : {
           ctrl: {}
           foo  ?  :  {}
           bar  ?  :  ""
          }|>)

    ps.lib("test").eachOwn |x|
    {
      if (x.name[0] == '_') return // TODO

      ctrl := x->ctrl
      verifyEq(ctrl.isOptional, false)
      verifyEq(ctrl->_optional.qname, "sys.Obj._optional")

      foo := x->foo
      verifyEq(foo.isOptional, true)
      verifyEq(x->foo->_optional.qname, "test.${x.name}.foo._optional")

      bar := x->bar
      verifyEq(bar.isOptional, true)
      verifyEq(x->bar->_optional.qname, "test.${x.name}.bar._optional")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Unnamed
//////////////////////////////////////////////////////////////////////////

  Void testUnnamed()
  {
    compileSrc(
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

    b := ps.lib("test")->B
    kids := Proto[,]
    b.eachOwn |x| { kids.add(x) }
    verifyEq(kids.size, 3)
    kids.each |kid| { verifyEq(kid.type.qname, "test.Box") }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private Proto get(Str qname)
  {
    ps.get(qname)
  }

  private ProtoSpace compile(Str[] libs)
  {
    this.ps = ProtoEnv.cur.compile(libs)
  }

  private ProtoSpace compileSrc(Str src)
  {
    prelude :=
     Str<|test #<
            version: "0.0.1"
          >
         |>
    src = prelude + src

    if (false)
    {
      echo("---")
      src.splitLines.each |line, i| { echo("${i+1}: $line") }
      echo("---")
    }

    return compile(["sys", src])
  }

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

