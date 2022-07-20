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
    ps := ProtoEnv.cur.compile(["sys"])
    ps.root.dump

    sys    := verifyLib(ps, "sys", "0.9.1")
    obj    := verifyProto(ps, "sys.Obj",    null,   null)
    marker := verifyProto(ps, "sys.Marker", obj,    null)
    val    := verifyProto(ps, "sys.Val",    obj,    null)
    scalar := verifyProto(ps, "sys.Scalar", val,    null)
    bool   := verifyProto(ps, "sys.Bool",   scalar, null)
    boolT  := verifyProto(ps, "sys.True",   bool,   "true")
    boolF  := verifyProto(ps, "sys.False",  bool,   "false")
    str    := verifyProto(ps, "sys.Str",    scalar, null)

/*
    objDoc    := verifyProto(ps, "sys.Obj._doc", str, null) // TODO "Root type for all objects")
    valDoc    := verifyProto(ps, "sys.Val._doc", objDoc, "Data value type")
    scalarDoc := verifyProto(ps, "sys.Scalar._doc", valDoc, "Scalar is an atomic value kind")

    verifySame(sys->Obj, obj)
    verifySame(obj->_doc, objDoc)
*/
    verifyErr(UnknownProtoErr#) { sys->Foo }
    verifyErr(UnknownProtoErr#) { obj->foo }
  }

  ProtoLib verifyLib(ProtoSpace ps, Str name, Str version)
  {
    path := Path(name)
    lib := ps.lib(name)
    verifySame(lib, ps.get(Path(name)))
    // TODO
    //verifyProto(ps, name, ps.get(Path("sys.Lib")), null)
    return lib
  }

  Proto verifyProto(ProtoSpace ps, Str path, Proto? type, Obj? val)
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

