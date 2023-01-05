//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Jan 2023  Brian Frank  Creation
//

using pog

**
** InfoTest
**
class InfoTest : Test
{
  Void testObjInfo()
  {
    p := load("sys.Obj", null)
    verifyEq(p.info.isObj,    true)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, false)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   false)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }

  Void testNoneInfo()
  {
    p := load("sys.None", "sys.Obj")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   true)
    verifyEq(p.info.isScalar, false)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   false)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }

  Void testScalar()
  {
    p := load("sys.Scalar", "sys.Obj")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, true)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   false)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }


  Void testMarker()
  {
    p := load("sys.Marker", "sys.Scalar")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, true)
    verifyEq(p.info.isMarker, true)
    verifyEq(p.info.isDict,   false)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }

  Void testStr()
  {
    p := load("sys.Str", "sys.Scalar")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, true)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   false)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }

  Void testInt()
  {
    p := load("sys.Int", "sys.Number")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, true)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   false)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }

  Void testDict()
  {
    p := load("sys.Dict", "sys.Obj")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, false)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   true)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }

  Void testList()
  {
    p := load("sys.List", "sys.Dict")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, false)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   true)
    verifyEq(p.info.isList,   true)
    verifyEq(p.info.isLib,    false)
  }

  Void testLib()
  {
    p := load("sys.Lib", "sys.Dict")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, false)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   true)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    false)
  }

  Void testSys()
  {
    p := load("sys", "sys.Lib")
    verifyEq(p.info.isObj,    false)
    verifyEq(p.info.isNone,   false)
    verifyEq(p.info.isScalar, false)
    verifyEq(p.info.isMarker, false)
    verifyEq(p.info.isDict,   true)
    verifyEq(p.info.isList,   false)
    verifyEq(p.info.isLib,    true)
  }

  Proto load(Str qnameStr, Str? isa)
  {
    qname := QName(qnameStr)
    libName := qname.lib
    lib := PogEnv.cur.load(libName.toStr)
    Proto p := qname == libName ? lib : lib.get(qname.name)
    verifyEq(p.qname, qname)
    verifyEq(p.isa?.qname?.toStr, isa)
    return p
  }
}