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

  Void testBasics()
  {
    // just sys
    ps := ProtoEnv.cur.compile(["sys"])
    verifyEq(ps.libs.size, 1)
    verifySame(ps.libs[0], ps.lib("sys"))
    verifySys(ps)

    // sys + ph
    ps = ProtoEnv.cur.compile(["sys", "ph"])
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

    obj    := verifyProto(ps, "sys.Obj",    null,   null)
    marker := verifyProto(ps, "sys.Marker", obj,    null)
    val    := verifyProto(ps, "sys.Val",    obj,    null)
    scalar := verifyProto(ps, "sys.Scalar", val,    null)
    bool   := verifyProto(ps, "sys.Bool",   scalar, null)
    boolT  := verifyProto(ps, "sys.True",   bool,   "true")
    boolF  := verifyProto(ps, "sys.False",  bool,   "false")
    str    := verifyProto(ps, "sys.Str",    scalar, null)

    objDoc    := verifyProto(ps, "sys.Obj._doc", str, "Root type for all objects")
    objDocDoc := verifyProto(ps, "sys.Obj._doc._doc", str, "Documentation for object")
    valDoc    := verifyProto(ps, "sys.Val._doc", objDoc, "Data value type")
    scalarDoc := verifyProto(ps, "sys.Scalar._doc", objDoc, "Scalar is an atomic value kind")

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

    na     := verifyProto(ps, "ph.Na",     sys->Obj)
    remove := verifyProto(ps, "ph.Remove", sys->Obj)
    ref    := verifyProto(ps, "ph.Ref",    sys->Scalar)
    grid   := verifyProto(ps, "ph.Grid",   sys->Collection)
    entity := verifyProto(ps, "ph.Entity", sys->Dict)
    id     := verifyProto(ps, "ph.Entity.id", ph->Ref)
    str    := verifyProto(ps, "ph.Entity.dis", sys->Str)
  }

  ProtoLib verifyLib(ProtoSpace ps, Str name, Str version)
  {
    path := Path(name)
    lib := ps.lib(name)
    verifySame(lib, ps.get(Path(name)))
    verifyProto(ps, name, ps.sys->Lib, null)
    verifyProto(ps, name+"._version", ps.sys->Lib->_version, version)
    verifyEq(lib.version, Version(version))
    return lib
  }

  Proto verifyProto(ProtoSpace ps, Str path, Proto? type, Obj? val := null)
  {
    p := ps.get(Path(path))
    verifyEq(p.name, path.split('.').last)
    verifyEq(p.path.toStr, path)
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

