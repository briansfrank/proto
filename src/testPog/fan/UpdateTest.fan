//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using pog
using pogLint
using haystack

**
** UpdateTest
**
class UpdateTest : AbstractCompileTest
{

//////////////////////////////////////////////////////////////////////////
// Set/Adds
//////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////
// Scalars
//////////////////////////////////////////////////////////////////////////

  Void testScalars()
  {
    graph = env.create(["sys", "sys.lint", "ph"])
    verifySys

    update |u|
    {
      data := u.clone(graph.sys->Dict)
      graph.add(data, "data")

      // sys types
      data.set("str",  "string")
      data.set("true", true)
      data.set("false", false)
      data.set("int",  7)
      data.set("float",  7f)
      data.set("date", Date.today)
      data.set("time", Time("14:00:00"))
      data.set("dt",   DateTime.boot)
      data.set("dur",  5sec)
      data.set("ver",  Version("1.2.3"))

      // sys lint types
      data.set("lintLevel", LintLevel.warn)

      // haystack types
      data.set("marker", Marker.val)
      data.set("num",    Number(123, Unit("kW")))
      data.set("na",     NA.val)
      data.set("remove", Remove.val)
      data.set("ref",    Ref("123-abc"))
      data.set("coord",  Coord(12f, 45f))
      data.set("sym1",    Symbol("foo"))
      data.set("sym2",    Symbol("foo-bar"))
      data.set("sym3",    Symbol("func:foo"))
      data.set("xstr",    XStr("Foo", "bar"))
    }
    verifySys
    // graph->data.dump

    // sys types
    verifyProto("data.str",   graph.sys->Str, "string")
    verifyProto("data.true",  graph.sys->Bool, true)
    verifyProto("data.false", graph.sys->Bool, false)
    verifyProto("data.int",   graph.sys->Int, 7)
    verifyProto("data.float", graph.sys->Float, 7f)
    verifyProto("data.date",  graph.sys->Date, Date.today)
    verifyProto("data.time",  graph.sys->Time, Time("14:00:00"))
    verifyProto("data.dt",    graph.sys->DateTime, DateTime.boot)
    verifyProto("data.dur",   graph.sys->Duration, 5sec)
    verifyProto("data.ver",   graph.sys->Version, Version("1.2.3"))

    // sys.lint types
    verifyProto("data.lintLevel",  graph.sys->lint->LintLevel, LintLevel.warn)

    // haystack types
    verifyProto("data.marker",  graph.sys->Marker, Marker.val)
    verifyProto("data.num",     graph.sys->Number, Number(123, Unit("kW")))
    verifyProto("data.ref",     graph->sys->Ref,   Ref("123-abc"))
    verifyProto("data.na",      graph->ph->NA,     NA.val)
    verifyProto("data.remove",  graph->ph->Remove, Remove.val)
    verifyProto("data.coord",   graph->ph->Coord,  Coord(12f, 45f))
    verifyProto("data.sym1",    graph->ph->Symbol, Symbol("foo"))
    verifyProto("data.sym2",    graph->ph->Symbol, Symbol("foo-bar"))
    verifyProto("data.sym3",    graph->ph->Symbol, Symbol("func:foo"))
    verifyProto("data.xstr",    graph->ph->XStr,   XStr("Foo", "bar"))
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