//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Dec 2022  Brian Frank  Creation
//

using pog
using pogLint
using haystack

**
** GraphTest
**
class GraphTest : AbstractCompileTest
{

//////////////////////////////////////////////////////////////////////////
// Ids
//////////////////////////////////////////////////////////////////////////

  Void testIds()
  {
     test := compileSrc(
     Str<|Alpha: {id:"@a"}
          Bravo: {
            id: "@b"
            charlie: {
              id:"@c"
              delta: {id:"@d"}
            }
          }
          |>)

    verifyId("test.Alpha", "@a")
    verifyId("test.Bravo", "@b")
    verifyId("test.Bravo.charlie", "@c")
    verifyId("test.Bravo.charlie.delta", "@d")
  }

  Void verifyId(Str qname, Str id)
  {
    p := graph.getq(qname)
    verifyEq(p.qname.toStr, qname)
    verifySame(graph.getById(id), p)
    verifySame(graph.getq(qname), p)
    verifySame(graph.getq(QName(qname)), p)
  }
}