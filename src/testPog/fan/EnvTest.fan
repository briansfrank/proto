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
** TODO: test lib qname, and lib children name errors
**
class EnvTest : Test
{
  Void testInstalled()
  {
    env := PogEnv.cur
    verifyEq(env.installed.contains("sys"), true)
    verifyEq(env.installed.contains("ph"), true)
    verifyEq(env.installed.contains("fooBar"), false)

    verifyEq(env.load("fooBar", false), null)
    verifyErr(UnknownLibErr#) { env.load("fooBar") }
    verifyErr(UnknownLibErr#) { env.load("fooBar", true) }
  }

//////////////////////////////////////////////////////////////////////////
// Sys
//////////////////////////////////////////////////////////////////////////

  Void testSys()
  {
    env := PogEnv.cur
    lib := env.load("sys")

    // lib meta
    verifySame(lib, env.load("sys"))
    verifyEq(lib.qname.toStr, "sys")
    verifySame(lib is Lib, true)
    verifyEq(lib.version, Version("0.9.1"))
    verifyEq(lib->_org->dis.val, "Project Haystack")

    // core system types
    verifyProto(lib,         "sys",        "sys.Lib")
    verifyProto(lib->Obj,    "sys.Obj",    null)
    verifyProto(lib->Dict,   "sys.Dict",   "sys.Obj")
    verifyProto(lib->Scalar, "sys.Scalar", "sys.Obj",   "")
    verifyProto(lib->Str,    "sys.Str",    "sys.Scalar", "")
    verifyProto(lib->Number, "sys.Number", "sys.Scalar", "0")
    verifyProto(lib->Int,    "sys.Int",    "sys.Number", "0")

    // get
    verifySame(lib.get("Number"), lib->Number)
    verifyEq(lib.get("NotThere", false), null)
    verifyErr(UnknownProtoErr#) { lib.get("NotThere") }
    verifyErr(UnknownProtoErr#) { lib.get("NotThere", true) }
  }

//////////////////////////////////////////////////////////////////////////
// Ph
//////////////////////////////////////////////////////////////////////////

  Void testPh()
  {
    env := PogEnv.cur
    lib := env.load("ph")

    // lib meta
    verifySame(lib, env.load("ph"))
    verifyEq(lib.qname.toStr, "ph")
    verifySame(lib is Lib, true)
    verifyEq(lib.version, Pod.find("ph").version)
    verifyEq(lib->_org->dis.val, "Project Haystack")

    // check some types
    verifyProto(lib,         "ph",        "sys.Lib")
    verifyProto(lib->Coord,  "ph.Coord",  "sys.Scalar", "C(0,0)")
    verifyProto(lib->Grid,   "ph.Grid",   "sys.Dict",   null)
  }

  Proto verifyProto(Proto p, Str qname, Str? isa, Obj? val := null)
  {
    // echo; echo("===== $qname [$p.typeof]"); p.print
    verifyEq(p.qname.toStr, qname)
    verifyEq(p.name, QName(qname).name)
    verifyEq(p.isa?.qname?.toStr, isa)
    verifyEq(p.hasVal, val != null)
    verifyEq(p.val(false), val)
    return p
  }
}