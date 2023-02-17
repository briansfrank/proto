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
// Query
//////////////////////////////////////////////////////////////////////////

  Void testQuery()
  {
    ahu       := rec(["id":Ref("ahu"), "dis":"AHU", "ahu":m, "equip":m])
      mode    := rec(["id":Ref("mode"), "dis":"Mode", "hvacMode":m, "point":m, "equipRef":ahu.id])
      dduct   := rec(["id":Ref("dduct"), "dis":"Discharge Duct", "duct":m, "equip":m, "equipRef":ahu.id])
        dtemp := rec(["id":Ref("dtemp"), "dis":"Discharge Temp", "temp":m, "point":m, "equipRef":dduct.id])
        dflow := rec(["id":Ref("dflow"), "dis":"Discharge Flow", "flow":m, "point":m, "equipRef":dduct.id])
        dfan  := rec(["id":Ref("dfan"), "dis":"Discharge Fan", "fan":m, "equip":m, "equipRef":dduct.id])
         drun := rec(["id":Ref("drun"), "dis":"Discharge Fan Run", "fan":m, "run":m, "point":m, "equipRef":dfan.id])

    // Point.equips
    verifyQuery(mode,  "Point->equips", [ahu])
    verifyQuery(dtemp, "Point->equips", [ahu, dduct])
    verifyQuery(drun,  "Point->equips", [ahu, dduct, dfan])

    // Equip.points
    verifyQuery(dfan,  "Equip->points", [drun])
    verifyQuery(dduct, "Equip->points", [dtemp, dflow, drun])
    verifyQuery(ahu, "  Equip->points", [mode, dtemp, dflow, drun])
  }

  Void verifyQuery(Dict rec, Str query, Dict[] expected)
  {
//    expr := "query($rec.id.toCode, $query)"
// TODO
expr := "query(${rec.id->toCode}, $query)"
    //echo("-- $expr")
    Grid actual := eval(expr)
    x := actual.sortDis.mapToList { it.dis }.join(",")
    y := Etc.sortDictsByDis(expected).join(",") { it.dis }
    //echo("   $x ?= $y")
    verifyEq(x, y)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Ref:Dict db := [:]

  Dict rec(Str:Obj tags)
  {
    Dict dict := Etc.makeDict(tags)
    db[dict.id] = dict
    return dict
  }

  Void verifyEval(Str expr, Obj? expect)
  {
    actual := eval(expr)
    //echo("-- $expr | $actual ?= $expect")
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

  override Dict[] readAll(Filter f) { test.db.vals.findAll { f.matches(it, this) } }

  override Dict? deref(Ref id) { test.db[id] }

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