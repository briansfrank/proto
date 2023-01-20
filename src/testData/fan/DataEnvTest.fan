//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data
using haystack::Marker
using haystack::Number
using haystack::Ref

**
** DataEnvTest
**
@Js
class DataEnvTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Sys Lib
//////////////////////////////////////////////////////////////////////////

  Void testSysLib()
  {
    // lib basics
    sys := verifyLibBasics("sys", typeof.pod.version)
    verifySame(env.lib("sys"), sys)
    verifyEq(sys.qname, "sys")
    verifyEq(sys.version, typeof.pod.version)
    verifySame(sys.meta.type, env.type("sys.Dict"))

    // types
    obj    := verifyLibType(sys, "Obj",    null)
    none   := verifyLibType(sys, "None",   obj)
    scalar := verifyLibType(sys, "Scalar", obj)
    str    := verifyLibType(sys, "Str",    scalar)
    uri    := verifyLibType(sys, "Uri",    scalar)
    dict   := verifyLibType(sys, "Dict",   obj)
    lib    := verifyLibType(sys, "Lib",    dict)
    org    := verifyLibType(sys, "LibOrg", dict)

    // slots
    verifySlot(org, "dis", str)
    verifySlot(org, "uri", uri)
  }

//////////////////////////////////////////////////////////////////////////
// Lint Lib
//////////////////////////////////////////////////////////////////////////

  Void testLintLib()
  {
    // lib basics
    lint := verifyLibBasics("sys.lint", typeof.pod.version)

    // function
    findAllType := verifyLibFunc(lint, "FindAllType")

    // TODO: simple test
    r := findAllType.call(env.emptyDict)
  }

//////////////////////////////////////////////////////////////////////////
// Ph Lib
//////////////////////////////////////////////////////////////////////////

  Void testPhLib()
  {
    // lib basics
    ph := verifyLibBasics("ph", Version("3.9.13"))

    entity := verifyLibType(ph, "Entity", env.type("sys.Dict"))
    equip  := verifyLibType(ph, "Equip",  entity)
    meter  := verifyLibType(ph, "Meter",  equip)

  }

//////////////////////////////////////////////////////////////////////////
// Lookups
//////////////////////////////////////////////////////////////////////////

  Void testLookups()
  {
    // sys
    sys := env.lib("sys")
    verifySame(env.lib("sys"), sys)
    verifySame(env.type("sys.Dict"), sys.type("Dict"))

    // bad libs
    verifyEq(env.lib("bad.one", false), null)
    verifyEq(env.type("bad.one.Foo", false), null)
    verifyErr(UnknownLibErr#) { env.lib("bad.one") }
    verifyErr(UnknownLibErr#) { env.lib("bad.one", true) }
    verifyErr(UnknownLibErr#) { env.type("bad.one.Foo") }
    verifyErr(UnknownLibErr#) { env.type("bad.one", true) }

    // good lib, bad type
    verifyEq(env.type("sys.Foo", false), null)
    verifyErr(UnknownTypeErr#) { env.type("sys.Foo") }
    verifyErr(UnknownTypeErr#) { env.type("sys.Foo", true) }
  }

//////////////////////////////////////////////////////////////////////////
// Scalars
//////////////////////////////////////////////////////////////////////////

  Void testScalars()
  {
    verifyScalar("hi", "sys.Str")
    verifyScalar(true, "sys.Bool")
    verifyScalar(`foo`, "sys.Uri")
    verifyScalar(123, "sys.Int")
    verifyScalar(123f, "sys.Float")
    verifyScalar(123sec,"sys.Duration")
    verifyScalar(Date.today, "sys.Date")
    verifyScalar(Time.now, "sys.Time")
    verifyScalar(DateTime.now, "sys.DateTime")

    verifyScalar(Marker.val,  "sys.Marker")
    verifyScalar(Number(123), "sys.Number")
    verifyScalar(Ref.gen,     "sys.Ref")

    // any other type is mapped as string
    me := env.obj(this)
    verifyEq(me.type.qname, "sys.Str")
    verifyEq(me, env.obj(this.toStr))
  }

  Void verifyScalar(Obj val, Str qname)
  {
    obj := env.obj(val)
    // echo(">> $obj.type | $obj")
    verifySame(obj.val, val)
    verifyEq(obj.type.qname, qname)
    verifySame(obj.type, env.type(qname))
    verifyEq(obj, env.obj(val))
    verifySame(env.obj(obj), obj)
  }

//////////////////////////////////////////////////////////////////////////
// Dicts
//////////////////////////////////////////////////////////////////////////

  Void testDicts()
  {
    verifyDict(Str:Obj[:])
    verifyDict(["str":"hi there!"])
    verifyDict(["str":"hi", "int":123])
  }

  Void verifyDict(Str:Obj map, Str qname := "sys.Dict")
  {
    d := env.dict(map)

    verifyEq(d.type.qname, qname)
    verifySame(d.type, env.type(qname))
    if (map.isEmpty) verifySame(d, env.emptyDict)
    verifySame(d.val, d)

    map.each |v, n|
    {
      verifyEq(d.has(n), true)
      verifyEq(d.missing(n), false)
      verifySame(d.get(n), v)
      verifySame(d.trap(n), v)
    }

    keys := map.keys
    if (keys.isEmpty)
      verifyEq(d.eachWhile |v,n| { "break" }, null)
    else
      verifyEq(d.eachWhile |v,n| { n == keys[0] ? "foo" : null }, "foo")

    verifyEq(d.has("badOne"), false)
    verifyEq(d.missing("badOne"), true)
    verifyEq(d.get("badOne", null), null)
    verifyEq(d.get("badOne", "foo"), "foo")

    verifySame(env.obj(d), d)
    dobj := env.obj(map)
    verifyEq(dobj is DataDict, true)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }

  DataLib verifyLibBasics(Str qname, Version version)
  {
    lib := env.lib(qname)

    verifySame(env.lib(qname), lib)
    verifyEq(lib.qname, qname)
    verifyEq(lib.version, version)
    verifySame(lib.meta.type, env.type("sys.Dict"))

    verifyEq(lib.type("Bad", false), null)
    verifyErr(UnknownTypeErr#) { lib.type("Bad") }
    verifyErr(UnknownTypeErr#) { lib.type("Bad", true) }

    return lib
  }

  DataType verifyLibType(DataLib lib, Str name, DataType? base)
  {
    type := lib.type(name)
    verifySame(lib.type(name), type)
    verifyEq(lib.types.containsSame(type), true)
    verifySame(type.base, base)
    verifyEq(type.qname, lib.qname + "." + name)
    verifyEq(type.toStr, type.qname)
    verifySame(type.meta.type, env.type("sys.Dict"))
    return type
  }

  DataFunc verifyLibFunc(DataLib lib, Str name)
  {
    func := (DataFunc)verifyLibType(lib, name, env.type("sys.Func"))
    verifySame(env.func(func.qname), func)
    verifySame(func.returns, func.slot("return"))
    verifyEq(func.params.join(",") { it.name }, func.slots.findAll { it.name != "return" }.join(",") { it.name })
    verifyEq(func.param("return", false), null)
    verifyErr(UnknownParamErr#) { func.param("return") }
    verifyErr(UnknownParamErr#) { func.param("foo") }
    return func
  }

  DataSlot verifySlot(DataType parent, Str name, DataType type)
  {
    slot := parent.slot(name)
    verifySame(parent.slot(name), slot)
    verifyEq(parent.slots.containsSame(slot), true)
    verifyEq(slot.qname, parent.qname + "." + name)
    verifyEq(slot.toStr, slot.qname)
    verifySame(slot.type, type)
    verifySame(slot.meta.type, env.type("sys.Dict"))
    return slot
  }

  Void dumpLib(DataLib lib)
  {
    echo("--- dump $lib.qname ---")
    lib.types.each |t|
    {
      hasSlots := !t.slots.isEmpty
      echo("$t.name: $t.base <$t.meta>" + (hasSlots ? " {" : ""))
      t.slots.each |s| { echo("  $s.name: <$s.meta> $s.type") }
      if (hasSlots) echo("}")
    }
  }

}