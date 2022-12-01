//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

using pog
using haystack

**
** I/O tests
**
class IOTest : AbstractCompileTest
{

//////////////////////////////////////////////////////////////////////////
// JSON AST
//////////////////////////////////////////////////////////////////////////

  Void testJsonAst()
  {
    compile(["sys", "ph"])
    verifyEq(graph.libs.size, 2)
    verifySame(graph.libs[0], graph.lib("ph"))
    verifySame(graph.libs[1], graph.lib("sys"))
    verifySys
    verifyPh

    // encode
    sb := StrBuf()
    PogEnv.cur.io.write("json-ast", graph, sb.out)
    json := sb.toStr

    // decode
    graph = env.io.read("json-ast", json.in)
    verifyEq(graph.libs.size, 2)
    verifySame(graph.libs[0], graph.lib("ph"))
    verifySame(graph.libs[1], graph.lib("sys"))
    verifySys
    verifyPh
  }

//////////////////////////////////////////////////////////////////////////
// Haystack
//////////////////////////////////////////////////////////////////////////

  Void testHaystack()
  {
    verifyHaystack(Etc.makeDict1("dis", "Hello"))

    verifyHaystack(Etc.makeDict([
      "str": "string",
      "marker": Marker.val,
      "date": Date("1996-10-15"),
      "time": Time.now,
      "ts": DateTime.now,
      "num": Number(123, Unit("%")),
      "ref": Ref.gen,
      "na": NA.val,
      "remove": Remove.val,
      "coord": Coord(75f, -10f),
      "sym": Symbol("site"),
      "xstr": XStr("Span", "today"),
     ]))
  }

  Void verifyHaystack(Obj val)
  {
    graph = env.io.read("haystack", val)
    data := graph->data
    // data.dump
    Etc.toGrid(val).each |expected, i|
    {
      actual := data.get("_$i")
      verifyHaystackDictEq(actual, expected)
    }
  }

  Void verifyHaystackEq(Proto p, Obj v)
  {
    if (v is Dict) return verifyHaystackDictEq(p, v)
    if (v is List) fail
    if (v is Grid) fail
    verifyHaystackScalarEq(p, v)
  }

  Void verifyHaystackDictEq(Proto p, Dict d)
  {
    verifyProto(p.qname, graph.sys->Dict, null, graph.tx)
    num := 0
    d.each |v, n|
    {
      verifyHaystackEq(p.get(n), v)
    }
  }

  Void verifyHaystackScalarEq(Proto p, Obj v)
  {
    type := p.type
    expectedName := v.typeof.name
    if (v is Symbol) expectedName = "Symbol"
    verifyEq(type.name, expectedName)

    verifyProto(p.qname, type, v, graph.tx)
  }
}


