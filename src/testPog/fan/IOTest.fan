//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

using pog
using pogc

**
** I/O tests
**
class IOTest : AbstractCompileTest
{
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
}