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
class DataSpecTest : AbstractDataTest
{

//////////////////////////////////////////////////////////////////////////
// Meta
//////////////////////////////////////////////////////////////////////////

  Void testMeta()
  {
    lib := compileLib(
      Str<|Foo: Dict <a:"A", b:"B">
           Bar: Foo <b:"B2", c:"C">
           Baz: Bar <c:"C2", d:"D">
           |>)

     // env.print(lib)

     verifyMeta(lib.slotOwn("Foo"), Str:Obj["a":"A", "b":"B"],  Str:Obj["a":"A", "b":"B"])
     verifyMeta(lib.slotOwn("Bar"), Str:Obj["b":"B2", "c":"C"],  Str:Obj["a":"A", "b":"B2", "c":"C"])
  }

  Void verifyMeta(DataSpec s, Str:Obj own, Str:Obj effective)
  {
    acc := Str:Obj[:]
    s.own.each |v, n| { acc[n] = v }
    verifyEq(acc, own)

    acc = Str:Obj[:]
    s.each |v, n| { acc[n] = v }
    acc.remove("doc")
    verifyEq(acc, effective)
  }

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
    // TODO
    //verifyIsa("ph.points::AirFlowSensor", "sys::Dict", true)

    verifyIsa("ph.points::ZoneAirTempSensor", "ph::Point", true)
    // TODO
    //verifyIsa("ph.points::ZoneAirTempSensor", "sys::Dict", true)
  }

  Void verifyIsa(Str an, Str bn, Bool expected)
  {
    a := env.type(an)
    b := env.type(bn)
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
    lib := compileLib(
      Str<|Foo: Dict {
             bar: Str?
             baz: Foo?
           }|>)

    //env.print(lib)

     str := env.type("sys::Str")
     maybe := env.type("sys::Maybe")
     foo := lib.slotOwn("Foo")

     bar := foo.slotOwn("bar")
     verifySame(bar.type, maybe)
     verifySame(bar["of"], str)

     baz := foo.slotOwn("baz")
     verifySame(baz.type, maybe)
     verifySame(baz["of"], foo)
   }

//////////////////////////////////////////////////////////////////////////
// And
//////////////////////////////////////////////////////////////////////////

  Void testAnd()
  {
    lib := compileLib(
      Str<|Foo: Dict
           Bar: Dict
           FooBar : Foo & Bar
           |>)

    //env.print(lib)

     and := env.type("sys::And")
     foo := lib.slotOwn("Foo")
     bar := lib.slotOwn("Bar")

     fooBar := lib.slotOwn("FooBar")
     verifySame(fooBar.type.base, and)
     verifySame(fooBar.type.isaAnd, true)
     verifyEq(fooBar["ofs"], DataSpec[foo,bar])
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

}

