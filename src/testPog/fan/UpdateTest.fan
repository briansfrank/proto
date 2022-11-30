//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using pog
using pogc

**
** UpdateTest
**
class UpdateTest : AbstractCompileTest
{
  Void testBasics()
  {
    graph = env.create(["sys"])
    verifySys

    // add
    newGraph := graph.update |u|
    {
      dict := graph.sys->Dict
      a := graph.add(u.clone(dict), "a")
      b := graph.set("b", u.clone(dict))
    }
newGraph.dump
    graph = newGraph
    verifySys
    verifyProto("a", graph.sys->Dict, null)
    verifyProto("b", graph.sys->Dict, null)

    // no-op load
    newGraph = graph.update |u| { u.load("sys") }
    verifySame(graph, newGraph)

    // no-op unload
    newGraph = graph.update |u| { u.unload("ph") }
    verifySame(graph, newGraph)

    // load lib
    /* TODO
    newGraph = graph.update |u| { u.load("ph") }
    verifyNotSame(graph, newGraph)
    verifyEq(graph.lib("ph", false)?.qname, null)
    verifyEq(newGraph.lib("ph", false)?.qname, "ph")
    verifySys
    verifyPh
    */
  }
}