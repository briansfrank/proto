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
  Void testStub()
  {
    compile(["sys", "sys.lint"])


    lib := graph.sys->lint
    verifyLib("sys.lint", "0.9.1")
    verifyEq(lib->LintReport.typeof, LintReport#)
    verifyEq(lib->LintItem.typeof, LintItem#)
    verifyEq(lib->LintPlan.typeof, LintPlan#)
    verifyEq(lib->LintRule.typeof, LintRule#)

    doc := graph.sys->Obj->_doc
    str := graph.sys->Str
    verifyProto("sys.lint.LintItem._doc", doc, "Lint item models one validation message")
    verifyProto("sys.lint.LintItem.msg", str)
    verifyProto("sys.lint.LintItem.msg._doc", doc, "Free form message string describing issue")

    graph := graph.update |u|
    {
      r := u.clone(lib->LintRule)
      i := u.clone(lib->LintItem)
      graph.set("rule", r)
      i.set("rule", r)
       .set("level", LintLevel.warn)
       .set("msg", "test item")
    }

    item := (LintItem)graph->item
    item.dump

  }
}