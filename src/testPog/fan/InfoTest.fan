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
    verifyInfo("sys.Obj",     null,         "isObj")
    verifyInfo("sys.None",    "sys.Obj",    "isNone")
    verifyInfo("sys.Scalar",  "sys.Obj",    "isScalar, fitsScalar")
    verifyInfo("sys.Marker",  "sys.Scalar", "isMarker, fitsScalar")
    verifyInfo("sys.Str",     "sys.Scalar", "fitsScalar")
    verifyInfo("sys.Int",     "sys.Number", "fitsScalar")
    verifyInfo("sys.Dict",    "sys.Obj",    "isDict, fitsDict")
    verifyInfo("sys.List",    "sys.Dict",   "isList, fitsDict, fitsList")
    verifyInfo("sys.Lib",     "sys.Dict",   "fitsDict")
    verifyInfo("sys",         "sys.Lib",    "isLibRoot, fitsDict")
  }

  Proto verifyInfo(Str qnameStr, Str? isa, Str expected)
  {
    qname := QName(qnameStr)
    libName := qname.lib
    lib := PogEnv.cur.load(libName.toStr)
    Proto p := qname == libName ? lib : lib.get(qname.name)
    verifyEq(p.qname, qname)
    verifyEq(p.isa?.qname?.toStr, isa)

    trues := expected.split(',')
    trues.each |x| { ProtoInfo#.method(x) }

    ProtoInfo#.methods.each |m|
    {
      if (m.parent == Obj#) return
      actual := m.callOn(p.info, null)
      expect := trues.contains(m.name)
      // echo("  > $m.name | $actual ?= $expect")
      verifyEq(expect, actual, "$qnameStr $m.name")
    }

    return p
  }
}