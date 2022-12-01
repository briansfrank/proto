//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

using pog
using pogc
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
    d.each |n, v|
    {
      verifyHaystackEq(p.get(n), v)
    }
  }

  Void verifyHaystackScalarEq(Proto p, Obj v)
  {
    // TODO
    verifyProto(p.qname, graph.sys->Str, v.toStr, graph.tx)
  }
}


