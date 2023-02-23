//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Jan 2023  Brian Frank  Creation
//

using util
using data2

**
** DataSpecTest
**
@Js
class DataSpecTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Is-A
//////////////////////////////////////////////////////////////////////////

  Void testIsa()
  {
    verifyIsa("sys::Obj", "sys::Obj", true)
    verifyIsa("sys::Obj", "sys::Str", false)

    verifyIsa("sys::Scalar", "sys::Obj",    true)
    verifyIsa("sys::Scalar", "sys::Scalar", true)
    verifyIsa("sys::Scalar", "sys::Str",    false)

    verifyIsa("sys::Str", "sys::Obj",    true)
    verifyIsa("sys::Str", "sys::Scalar", true)
    verifyIsa("sys::Str", "sys::Str",    true)
    verifyIsa("sys::Str", "sys::Int",    false)

    verifyIsa("sys::Int", "sys::Obj",    true)
    verifyIsa("sys::Int", "sys::Scalar", true)
    verifyIsa("sys::Int", "sys::Number", true)
    verifyIsa("sys::Int", "sys::Int",    true)
    verifyIsa("sys::Int", "sys::Float",  false)

    verifyIsa("sys::Seq", "sys::Seq",  true)
    verifyIsa("sys::Seq", "sys::Dict", false)

    verifyIsa("sys::Dict", "sys::Seq",  true)
    verifyIsa("sys::Dict", "sys::Dict", true)
    verifyIsa("sys::Dict", "sys::List", false)

    verifyIsa("sys::List", "sys::Seq",  true)
    verifyIsa("sys::List", "sys::List", true)
    verifyIsa("sys::List", "sys::Dict", false)

    verifyIsa("sys::Maybe", "sys::Maybe", true)
    verifyIsa("sys::And",   "sys::And",   true)
    verifyIsa("sys::Or",    "sys::Or",    true)

    verifyIsa("ph.points::AirFlowSensor", "sys::And", true)
    verifyIsa("ph.points::AirFlowSensor", "ph::Point", true)
    verifyIsa("ph.points::AirFlowSensor", "ph.points::Sensor", true)
    verifyIsa("ph.points::ZoneAirTempSensor", "ph.Point", true)
    verifyIsa("ph.points::ZoneAirTempSensor", "sys::Dict", true)
  }

  Void verifyIsa(Str an, Str bn, Bool expected)
  {
    a := env.spec(an)
    b := env.spec(bn)
    m := a.typeof.method("isa${b.name}", false)
    // echo("$a isa $b = ${a.isa(b)} ?= $expected [$m]")
    verifyEq(a.isa(b), expected)
    if (m != null) verifyEq(m.call(a), expected)
  }

//////////////////////////////////////////////////////////////////////////
// Maybe
//////////////////////////////////////////////////////////////////////////

  Void testMaybe()
  {
    lib := compile(
      Str<|Foo: Dict {
             bar: Str?
             baz: Foo?
           }|>)

    //env.print(lib)

     str := env.spec("sys::Str")
     maybe := env.spec("sys::Maybe")
     foo := lib.get("Foo")

     bar := foo.get("bar")
     verifySame(bar.base, maybe)
     verifySame(bar.meta["of"], str)

     baz := foo.get("baz")
     verifySame(baz.base, maybe)
     verifySame(baz.meta["of"], foo)
   }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

/*
  Void testReflection()
  {
    ph := env.lib("ph")
    phx := env.lib("ph.points")

    equipSlots       := ["equip:Marker", "points:Query"]
    meterSlots       := equipSlots.dup.add("meter:Marker")
    elecMeterSlots   := meterSlots.dup.add("elec:Marker")
    acElecMeterSlots := elecMeterSlots.dup.add("ac:Marker")

    verifySlots(ph->Equip,       equipSlots)
    verifySlots(ph->Meter,       meterSlots)
    verifySlots(ph->ElecMeter,   elecMeterSlots)
    verifySlots(ph->AcElecMeter, acElecMeterSlots)

    ptSlots    := ["point:Marker", "equips:Query"]
    numPtSlots := ptSlots.dup.addAll(["kind:Str", "unit:Str"])
    afSlots    := numPtSlots.dup.addAll(["air:Marker", "flow:Marker"])
    afsSlots   := afSlots.dup.add("sensor:Marker")
    dafsSlots  := afsSlots.dup.add("discharge:Marker")
    verifySlots(ph->Point, ptSlots)
    verifySlots(phx->NumberPoint, numPtSlots)
    verifySlots(phx->AirFlowPoint, afSlots)
    verifySlots(phx->AirFlowSensor, afsSlots)
    verifySlots(phx->DischargeAirFlowSensor, dafsSlots)
  }

  Void verifySlots(DataSpec t, Str[] expected)
  {
    slots := t.slots
    slots.each |s, i|
    {
      verifyEq("$s.name:$s.slotType.name", expected[i])
    }
    verifyEq(slots.size, expected.size)
  }
  */

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  DataEnv env() { DataEnv.cur }

  DataLib compile(Str s) { env.compile(s) }

}

