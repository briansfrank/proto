//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using pog

**
** Base clas for tests which compile new pogs
**
abstract class AbstractCompileTest : Test
{

  PogEnv env() { PogEnv.cur }

  Graph? graph

  Proto getq(Str qname)
  {
    graph.getq(qname)
  }

  Graph compile(Str[] libs)
  {
    this.graph = PogEnv.cur.compile(libs)
  }

  Lib compileSrc(Str src)
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

    compile(["sys", src])
    return graph.lib("test")
  }

  Lib verifyLib(Str qname, Str version)
  {
    lib := graph.lib(qname)
    verifySame(lib, graph.get(qname))
    verifyProto(qname, graph.sys->Lib, null)
    verifyProto(qname+"._version", graph.sys->Lib->_version, version)
    verifyEq(lib.version, Version(version))
    return lib
  }

  Proto verifyProto(Str qname, Proto? type, Obj? val := null)
  {
    p := getq(qname)
    // echo("$p.loc [$p.qname]")
    verifyEq(p.name, qname.split('.').last)
    verifyEq(p.qname, qname)
    verifySame(p.type, type)
    verifyEq(p.toStr, qname)
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

  Void verifySys()
  {
    sys := verifyLib("sys", "0.9.1")
    verifySame(graph->sys, sys)

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

  Void verifyPh()
  {
    ph := verifyLib("ph", "3.9.12")
    verifySame(graph->ph, ph)

    sys := graph->sys

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
}

