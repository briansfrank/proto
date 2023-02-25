//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data2

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

    // types
    obj    := verifyLibType(sys, "Obj",    null)
    none   := verifyLibType(sys, "None",   obj)
    scalar := verifyLibType(sys, "Scalar", obj)
    str    := verifyLibType(sys, "Str",    scalar)
    uri    := verifyLibType(sys, "Uri",    scalar)
    seq    := verifyLibType(sys, "Seq",    obj)
    dict   := verifyLibType(sys, "Dict",   seq)
    list   := verifyLibType(sys, "List",   seq)
    lib    := verifyLibType(sys, "Lib",    dict)
    spec   := verifyLibType(sys, "Spec",   dict)
    type   := verifyLibType(sys, "Type",   spec)
    org    := verifyLibType(sys, "LibOrg", dict)

    // slots
    orgDis := verifySlot(org, "dis", str)
    orgUri := verifySlot(org, "uri", uri)

    // env.print(sys)
  }

//////////////////////////////////////////////////////////////////////////
// Ph Lib
//////////////////////////////////////////////////////////////////////////

  Void testPhLib()
  {
    // lib basics
    ph := verifyLibBasics("ph", Version("3.9.13"))

    entity := verifyLibType(ph, "Entity", env.type("sys::Dict"))
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
    verifySame(env.type("sys::Dict"), sys.slotOwn("Dict"))

    // bad libs
    verifyEq(env.lib("bad.one", false), null)
    verifyEq(env.type("bad.one::Foo", false), null)
    verifyErr(UnknownLibErr#) { env.lib("bad.one") }
    verifyErr(UnknownLibErr#) { env.lib("bad.one", true) }
    verifyErr(UnknownLibErr#) { env.type("bad.one::Foo") }
    verifyErr(UnknownLibErr#) { env.type("bad.one::Foo", true) }

    // good lib, bad type
    verifyEq(env.type("sys::Foo", false), null)
    verifyErr(UnknownSpecErr#) { env.type("sys::Foo") }
    verifyErr(UnknownSpecErr#) { env.type("sys::Foo", true) }
  }

//////////////////////////////////////////////////////////////////////////
// TypeOf
//////////////////////////////////////////////////////////////////////////

/*
  Void testTypeOf()
  {
    verifyTypeOf(null, "sys::None")
    verifyTypeOf("hi", "sys::Str")
    verifyTypeOf(true, "sys::Bool")
    verifyTypeOf(`foo`, "sys::Uri")
    verifyTypeOf(123, "sys::Int")
    verifyTypeOf(123f, "sys::Float")
    verifyTypeOf(123sec,"sys::Duration")
    verifyTypeOf(Date.today, "sys::Date")
    verifyTypeOf(Time.now, "sys::Time")
    verifyTypeOf(DateTime.now, "sys::DateTime")

    verifyTypeOf(Marker.val,  "sys::Marker")
    verifyTypeOf(Number(123), "sys::Number")
    verifyTypeOf(Ref.gen,     "sys::Ref")

    verifyEq(env.typeOf(Buf(), false), null)
    verifyErr(UnknownTypeErr#) { env.typeOf(this) }
    verifyErr(UnknownTypeErr#) { env.typeOf(this, true) }
  }

  Void verifyTypeOf(Obj? val, Str qname)
  {
    t := env.typeOf(val)
    // echo(">> $val | $t ?= $qname")
    verifyEq(t.qname, qname)
    verifySame(t, env.type(qname))
  }
*/

//////////////////////////////////////////////////////////////////////////
// Dicts
//////////////////////////////////////////////////////////////////////////

  Void testDicts()
  {
    verifyDict(Str:Obj[:])
    verifyDict(["str":"hi there!"])
    verifyDict(["str":"hi", "int":123])
  }

  Void verifyDict(Str:Obj map, Str qname := "sys::Dict")
  {
    d := env.dict(map)

    type := (DataType)d.spec

    verifyEq(type.qname, qname)
    verifySame(d.spec, env.type(qname))
    if (map.isEmpty) verifySame(d, env.emptyDict)

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
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }

  DataLib verifyLibBasics(Str qname, Version version)
  {
    lib := env.lib(qname)

    verifySame(env.lib(qname), lib)
    verifySame(lib.env, env)
    verifyEq(lib.qname, qname)
    verifyEq(lib.version, version)
    verifySame(lib.type, env.type("sys::Lib"))
    verifySame(lib.spec, env.type("sys::Spec"))

    verifyEq(lib.slotOwn("Bad", false), null)
    verifyErr(UnknownSpecErr#) { lib.slotOwn("Bad") }
    verifyErr(UnknownSpecErr#) { lib.slotOwn("Bad", true) }

    return lib
  }

  DataSpec verifyLibType(DataLib lib, Str name, DataType? base)
  {
    DataType type := lib.slotOwn(name)
    verifySame(type.env, env)
    verifySame(type.lib, lib)
    verifySame(lib.slotOwn(name), type)
//   verifyEq(lib.list.containsSame(type), true)
    verifySame(type.type, type)
    verifySame(type.base, base)
    verifyEq(type.qname, lib.qname + "::" + name)
    verifyEq(type.toStr, type.qname)
    verifySame(type.spec, env.type("sys::Type"))
    return type
  }

  DataSpec verifySlot(DataSpec parent, Str name, DataType type)
  {
    slot := parent.slotOwn(name)
    verifyEq(slot.typeof.qname, "xeto2::MSpec") // not type
    verifySame(slot.env, env)
    verifySame(parent.slotOwn(name), slot)
//    verifyEq(parent.list.containsSame(slot), true)
//    verifyEq(slot.qname, parent.qname + "." + name)
//    verifyEq(slot.toStr, slot.qname)
    verifySame(slot.type, type)
    verifySame(slot.spec, env.type("sys::Spec"))
    return slot
  }

  Void dumpLib(DataLib lib)
  {
    echo("--- dump $lib.qname ---")
    lib.slotsOwn.each |DataType t|
    {
      hasSlots := !t.slotsOwn.isEmpty
      echo("$t.name: $t.type <$t>" + (hasSlots ? " {" : ""))
      //t.list.each |s| { echo("  $s.name: <$s.meta> $s.base") }
      if (hasSlots) echo("}")
    }
  }

}