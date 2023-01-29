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
using axonsh

**
** AxonTest
**
class AxonTest : HaystackTest
{

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////
// Is-a
//////////////////////////////////////////////////////////////////////////

  Void testIsa()
  {
    verifyEval("isa(null, None)", true)
    verifyEval("isa(null, Str)", false)
    verifyEval("isa(\"hi\", Str)", true)
    verifyEval("isa(\"hi\", Number)", false)
    verifyEval("isa(123, Number)", true)
    verifyEval("isa({}, Dict)", true)
    verifyEval("isa({}, Point)", false)
    verifyEval("isa({point}, Point)", false)
  }

//////////////////////////////////////////////////////////////////////////
// Fits
//////////////////////////////////////////////////////////////////////////

  Void testFits()
  {
    verifyEval("fits(null, None)", true)
    verifyEval("fits(null, Str)", false)
    verifyEval("fits(\"hi\", Str)", true)
    verifyEval("fits(\"hi\", Number)", false)
    verifyEval("fits(123, Number)", true)
    verifyEval("fits({}, Dict)", true)
    verifyEval("fits({}, Point)", false)
    verifyEval("fits({point}, Point)", true)
    verifyEval("fits({equip}, Equip)", true)
    verifyEval("fits({equip}, Meter)", false)
    verifyEval("fits({equip, meter}, Meter)", true)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Void verifyEval(Str expr, Obj? expect)
  {
    actual := eval(expr)
    echo("-- $expr | $actual ?= $expect")
    verifyEq(actual, expect)
  }

  AxonContext makeContext() { TestContext(this) }

  Obj? eval(Str s) { makeContext.eval(s) }

  DataEnv env() { DataEnv.cur }
}

**************************************************************************
** TestContext
**************************************************************************

internal class TestContext : AxonContext
{
  new make(AxonTest test)
  {
    this.test = test

    funcs := Str:Fn[:]
    funcs.addAll(FantomFn.reflectType(CoreLib#))
    funcs.addAll(FantomFn.reflectType(XFuncs#))
    this.funcs = funcs
  }

  AxonTest test

  Str:Fn funcs

  override Dict? deref(Ref id) { null }

  override FilterInference inference() { FilterInference.nil }

  override Dict toDict() { Etc.emptyDict }

  override Namespace ns() { test.ns }

  override DataEnv data() { test.env }

  override DataType? findType(Str name, Bool checked := true)
  {
    t := data.lib("sys").libType(name, false)
    if (t != null) return t
    return data.lib("ph").libType(name, checked)
  }

  override Fn? findTop(Str name, Bool checked := true)
  {
    if (name.contains("::")) name = name[name.indexr(":")+1..-1]
    return funcs.getChecked(name, checked)
  }
}