//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Jan 2023  Brian Frank  Creation
//

using util
using data
using haystackx
using axonx

**
** AxonTest
**
@Js
class AxonTest : HaystackTest
{
  Void testType()
  {
    verifyTypeExpr("Str", env.type("sys.Str"))
  }

  Void verifyTypeExpr(Str expr, DataType expect)
  {
    //echo("-- verifyType: $expr")
    actual := eval(expr)
    //echo("   $actual ?= $expect")
    verifyEq(actual, expect)
  }

  AxonContext makeContext() { TestContext(this) }

  Obj? eval(Str s) { makeContext.eval(s) }

  DataEnv env() { DataEnv.cur }
}

**************************************************************************
** TestContext
**************************************************************************

@Js
internal class TestContext : AxonContext
{
  new make(AxonTest test) { this.test = test }

  AxonTest test

  static const Str:Fn core := FantomFn.reflectType(CoreLib#)

  override Dict? deref(Ref id) { null }

  override FilterInference inference() { FilterInference.nil }

  override Dict toDict() { Etc.emptyDict }

  override Namespace ns() { test.ns }

  override DataType? findType(Str name, Bool checked := true)
  {
    DataEnv.cur.lib("sys").libType(name, checked)
  }

  override Fn? findTop(Str name, Bool checked := true)
  {
    if (name.contains("::")) name = name[name.indexr(":")+1..-1]
    return core.getChecked(name, checked)
  }
}