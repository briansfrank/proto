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
  Void testSets()
  {
    graph = env.create(["sys"])
    verifySys
    verifyProto("", graph.sys->Dict, null, 0)
    verifyProto("sys", graph.sys->Lib, null, 0)
    verifyProto("sys._version", graph.sys->Lib->_version, graph.sys.version.toStr, 0)

    // set/add
    update |u|
    {
      dict := graph.sys->Dict
      graph.add(u.clone(dict), "a")
      graph.set("b", u.clone(dict))
    }
    verifySys
    verifyProto("", graph.sys->Dict, null, 1)
    verifyProto("sys", graph.sys->Lib, null, 0)
    verifyProto("sys._version", graph.sys->Lib->_version, graph.sys.version.toStr, 0)
    verifyProto("a", graph.sys->Dict, null, 1)
    verifyProto("b", graph.sys->Dict, null, 1)

    // set/add deep
    update |u|
    {
      dict := graph.sys->Dict
      c := u.clone(dict)
      d := u.clone(dict)
      e := u.clone(dict)
      graph["c"] = c
      c.set("d", d) // TODO: change this to set operator
      d.add(e, "e")
      d.add(u.clone(dict))
      d.add(u.clone(dict))

      // verify exceptions
      verifyErr(DupProtoNameErr#) { graph.add(u.clone(dict), "a") }
      verifyErr(DupProtoNameErr#) { d.add(u.clone(dict), "e") }
      verifyErr(ProtoAlreadyParentedErr#) { d.add(e, "someName") }
    }
    verifySys
    verifyProto("", graph.sys->Dict, null, 2)
    verifyProto("sys", graph.sys->Lib, null, 0)
    verifyProto("sys._version", graph.sys->Lib->_version, graph.sys.version.toStr, 0)
    verifyProto("a", graph.sys->Dict, null, 1)
    verifyProto("b", graph.sys->Dict, null, 1)
    verifyProto("c", graph.sys->Dict, null, 2)
    verifyProto("c.d", graph.sys->Dict, null, 2)
    verifyProto("c.d.e", graph.sys->Dict, null, 2)
    verifyProto("c.d._0", graph.sys->Dict, null, 2)
    verifyProto("c.d._1", graph.sys->Dict, null, 2)
  }

  Void update(|Update| f)
  {
    newGraph := graph.update(f)
    verifyNotSame(graph, newGraph)
    verifyEq(graph.tx+1, newGraph.tx)
    graph = newGraph
  }

  /* TODO
  Void testLoad()
  {
    // no-op load
    newGraph = graph.update |u| { u.load("sys") }
    verifySame(graph, newGraph)

    // no-op unload
    newGraph = graph.update |u| { u.unload("ph") }
    verifySame(graph, newGraph)

    // load lib
    newGraph = graph.update |u| { u.load("ph") }
    verifyNotSame(graph, newGraph)
    verifyEq(graph.lib("ph", false)?.qname, null)
    verifyEq(newGraph.lib("ph", false)?.qname, "ph")
    verifySys
    verifyPh
  }
  */

}