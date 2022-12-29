//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Dec 2022  Brian Frank  Creation
//

using pog

**
** PogEnv tests
**
class EnvTest : Test
{
  Void testSys()
  {
    env := PogEnv.cur
    lib := env.load("sys")
    verifySame(lib, env.load("sys"))

    verifyProto(lib,         "sys",        "sys.Lib")
    verifyProto(lib->Obj,    "sys.Obj",    null)
    verifyProto(lib->Dict,   "sys.Dict",   "sys.Obj")
    verifyProto(lib->Scalar, "sys.Scalar", "sys.Obj",   "")
    verifyProto(lib->Str,    "sys.Str",    "sys.Scalar", "")
    verifyProto(lib->Number, "sys.Number", "sys.Scalar", "0")
    verifyProto(lib->Int,    "sys.Int",    "sys.Number", "0")

    verifySame(lib.get("Number"), lib->Number)
    verifyEq(lib.get("NotThere", false), null)
    verifyErr(UnknownProtoErr#) { lib.get("NotThere") }
    verifyErr(UnknownProtoErr#) { lib.get("NotThere", true) }
  }

  Proto verifyProto(Proto p, Str qname, Str? isa, Obj? val := null)
  {
    verifyEq(p.qname.toStr, qname)
    verifyEq(p.name, QName(qname).name)
    verifyEq(p.isa?.qname?.toStr, isa)
    verifyEq(p.hasVal, val != null)
    verifyEq(p.val(false), val)
    return p
  }
}