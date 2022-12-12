//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Dec 2022  Brian Frank  Creation
//

using pog
using pogLint
using haystack

**
** ScalarTest
**
class ScalarTest : AbstractCompileTest
{

//////////////////////////////////////////////////////////////////////////
// Defaults
//////////////////////////////////////////////////////////////////////////

  Void testDefaults()
  {
    graph = env.create(["sys", "ph"])
    verifyDefault("sys.Scalar",   "",         "")
    verifyDefault("sys.Number",   "0",         0)
    verifyDefault("sys.Int",      "0",         0)
    verifyDefault("sys.Float",    "0",         0f)
    verifyDefault("sys.Duration", "0",         0sec)
    verifyDefault("sys.Str",      "",          "")
    verifyDefault("sys.Uri",      "",          ``)
    verifyDefault("sys.Version",  "0",          Version.defVal)
    verifyDefault("sys.Date",     "2000-01-01", Date.defVal)
    verifyDefault("sys.Time",     "00:00:00",   Time.defVal)
    verifyDefault("sys.DateTime", "2000-01-01T00:00:00Z UTC", DateTime.defVal)

    // TODO: what to do with these...
    /*
    verifyDefault("ph.Symbol",    "x",           Symbol("x"))
    verifyDefault("ph.Coord",     "C(0.0,0.0)",  Coord.defVal)
    verifyDefault("ph.XStr",      "Nil(\"\")",   XStr.defVal)
    */
  }

  Void verifyDefault(Str qname, Str expected, Obj val)
  {
    p := graph.getq(qname)
    // echo("-- $qname ${p.val(false)} ?= $expected")
    verifyEq(p.val.toStr, expected)
    // TODO verifyEq(p.val, val)
  }
}