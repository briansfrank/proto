//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data

**
** DataEnvTest
**
@Js
class DataEnvTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Sys Lib
//////////////////////////////////////////////////////////////////////////

  Void testSys()
  {
    // lib basics
    sys := env.lib("sys")
    verifySame(env.lib("sys"), sys)
    verifyEq(sys.qname, "sys")
    verifyEq(sys.version, typeof.pod.version)

    // types
    obj    := verifyLibType(sys, "Obj",    null)
    none   := verifyLibType(sys, "None",   obj)
    scalar := verifyLibType(sys, "Scalar", obj)
    str    := verifyLibType(sys, "Str",    scalar)
    uri    := verifyLibType(sys, "Uri",    scalar)
    dict   := verifyLibType(sys, "Dict",   obj)
    lib    := verifyLibType(sys, "Lib",    dict)
    org    := verifyLibType(sys, "LibOrg", dict)

    // bad types
    verifyEq(sys.type("Bad", false), null)
    verifyErr(UnknownTypeErr#) { sys.type("Bad") }
    verifyErr(UnknownTypeErr#) { sys.type("Bad", true) }

    // slots
    verifySlot(org, "dis", str)
    verifySlot(org, "uri", uri)

    /*
    echo("--- dump ---")
    sys.types.each |t|
    {
      hasSlots := !t.slots.isEmpty
      echo("$t.name: $t.base <$t.meta>" + (hasSlots ? " {" : ""))
      t.slots.each |s| { echo("  $s.name: <$s.meta> $s.type") }
      if (hasSlots) echo("}")
    }
    */
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
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }

  DataType verifyLibType(DataLib lib, Str name, DataType? base)
  {
    type := lib.type(name)
    verifySame(lib.type(name), type)
    verifyEq(lib.types.containsSame(type), true)
    verifySame(type.base, base)
    verifyEq(type.qname, lib.qname + "." + name)
    verifyEq(type.toStr, type.qname)
    return type
  }

  DataSlot verifySlot(DataType parent, Str name, DataType type)
  {
    slot := parent.slot(name)
    verifySame(parent.slot(name), slot)
    verifyEq(parent.slots.containsSame(slot), true)
    verifyEq(slot.qname, parent.qname + "." + name)
    verifyEq(slot.toStr, slot.qname)
    verifySame(slot.type, type)
    return slot
  }

}