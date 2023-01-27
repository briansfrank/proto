//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Jan 2023  Brian Frank  Creation
//

using util
using data

**
** DataTypeTest
**
@Js
class DataTypeTest : Test
{

  Void testIsa()
  {
    verifyIsa("sys.Obj", "sys.Obj", true)
    verifyIsa("sys.Obj", "sys.Str", false)

    verifyIsa("sys.Scalar", "sys.Obj",    true)
    verifyIsa("sys.Scalar", "sys.Scalar", true)
    verifyIsa("sys.Scalar", "sys.Str",    false)

    verifyIsa("sys.Str", "sys.Obj",    true)
    verifyIsa("sys.Str", "sys.Scalar", true)
    verifyIsa("sys.Str", "sys.Str",    true)
    verifyIsa("sys.Str", "sys.Int",    false)

    verifyIsa("sys.Int", "sys.Obj",    true)
    verifyIsa("sys.Int", "sys.Scalar", true)
    verifyIsa("sys.Int", "sys.Number", true)
    verifyIsa("sys.Int", "sys.Int",    true)
    verifyIsa("sys.Int", "sys.Float",  false)

    verifyIsa("sys.Seq", "sys.Seq",  true)
    verifyIsa("sys.Seq", "sys.Dict", false)

    verifyIsa("sys.Dict", "sys.Seq",  true)
    verifyIsa("sys.Dict", "sys.Dict", true)
    verifyIsa("sys.Dict", "sys.List", false)

    verifyIsa("sys.List", "sys.Seq",  true)
    verifyIsa("sys.List", "sys.List", true)
    verifyIsa("sys.List", "sys.Dict", false)

    verifyIsa("sys.Maybe", "sys.Maybe", true)
    verifyIsa("sys.And",   "sys.And",   true)
    verifyIsa("sys.Or",    "sys.Or",    true)
  }

  Void verifyIsa(Str an, Str bn, Bool expected)
  {
    a := env.type(an)
    b := env.type(bn)
    m := a.typeof.method("isa${b.name}", false)
    echo("$a isa $b = ${a.isa(b)} ?= $expected [$m]")
    verifyEq(a.isa(b), expected)
    if (m != null) verifyEq(m.call(a), expected)
  }

  DataEnv env() { DataEnv.cur }

}