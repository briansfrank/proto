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
  Void testSys()
  {
    // lib basics
    env := DataEnv.cur
    sys := env.load("sys")
    verifySame(env.load("sys"), sys)
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

    echo("--- dump ---")
    sys.types.each |t|
    {
      hasSlots := !t.slots.isEmpty
      echo("$t.name: $t.base <$t.meta>" + (hasSlots ? " {" : ""))
      t.slots.each |s| { echo("  $s.name: <$s.meta> $s.type") }
      if (hasSlots) echo("}")
    }
  }

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