//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 2022  Brian Frank  Creation
//

using pog
using pogLint

**
** LintTest
**
class LintTest : AbstractCompileTest
{

//////////////////////////////////////////////////////////////////////////
// Stub
//////////////////////////////////////////////////////////////////////////

  Void testStub()
  {
    compile(["sys", "sys.lint"])


    lib := graph.sys->lint
    verifyLib("sys.lint", "0.9.1")
    verifyEq(lib->LintReport.typeof, LintReport#)
    verifyEq(lib->LintItem.typeof, LintItem#)
    verifyEq(lib->LintPlan.typeof, LintPlan#)

    doc := graph.sys->Obj->_doc
    str := graph.sys->Str
    verifyProto("sys.lint.LintItem._doc", doc, "Lint item models one validation message")
    verifyProto("sys.lint.LintItem.msg", str)
    verifyProto("sys.lint.LintItem.msg._doc", doc, "Free form message string describing issue")

    graph := graph.update |u|
    {
      x := u.clone(lib->LintItem)
      graph.set("x", x)
      x.set("level", LintLevel.warn)
       .set("msg", "test a")
    }

    x := (LintItem)graph->x
    verifyEq(x.level, LintLevel.warn)
    verifyEq(x.msg, "test a")

    graph = graph.update |u|
    {
      x.set("level", LintLevel.info)
       .set("msg", "test b")
    }

    verifyNotSame(graph->x, x)
    x = graph->x
    verifyEq(x.level, LintLevel.info)
    verifyEq(x.msg, "test b")
  }

//////////////////////////////////////////////////////////////////////////
// Test Cases
//////////////////////////////////////////////////////////////////////////

  Void testCases()
  {
    PogTestReader(`test/lint/`).readEach |c|
    {
      verifyCase(c)
    }
  }

  Void verifyCase(PogTestCase c)
  {
    echo("   $c.doc [$c.loc]")
    test := compileSrc(c.in)
    expected := c.out.splitLines

    lint := graph.lint
    report := lint.report
    // echo; test.dump; echo("---"); report.dump
    verifySame(lint.report, report)
    verifyEq(lint.isOk, false)
    verifyEq(lint.isErr, true)

    i := 0
    report->items.eachOwn |item|
    {
      e := expected[i++].split('|')
      if (item.name == "_of") return
      verifyEq(item->level.val, e[0])
      verifyEq(item->target.val, e[1])
      verifyEq(item->msg.val, e[2])
    }
    verifyEq(i, expected.size)
  }
}