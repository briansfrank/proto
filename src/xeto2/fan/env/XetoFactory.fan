//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Aug 2022  Brian Frank  Creation
//

using util

**
** XetoFactory maps between Xeto and Fantom types
**
@Js
internal const class XetoFactory
{
  new make()
  {
    b := XetoFactoryBuilder()
    this.fromXeto = b.fromXeto
    this.fromFantom = b.fromFantom
    this.marker = fromXeto["sys::Marker"].fantom.field("val").get(null)
  }

  const Str:XetoScalarType fromXeto
  const Type:XetoScalarType fromFantom
  const Obj marker
}

**************************************************************************
** XetoFactoryBuilder
**************************************************************************

@Js
internal class XetoFactoryBuilder
{
  new make()
  {
    pod := Pod.find("sys")
    mapScalar("sys::Str",      pod.type("Str"))
    mapScalar("sys::Bool",     pod.type("Bool"))
    mapScalar("sys::Int",      pod.type("Int"))
    mapScalar("sys::Float",    pod.type("Float"))
    mapScalar("sys::Duration", pod.type("Duration"))
    mapScalar("sys::Date",     pod.type("Date"))
    mapScalar("sys::Time",     pod.type("Time"))
    mapScalar("sys::DateTime", pod.type("DateTime"))
    mapScalar("sys::Uri",      pod.type("Uri"))
    mapScalar("sys::Version",  pod.type("Version"))

    pod = Pod.find("haystack")
    mapScalar("sys::Marker",   pod.type("Marker"))
    mapScalar("sys::Number",   pod.type("Number"))
    mapScalar("sys::Ref",      pod.type("Ref"))
    mapScalar("ph::NA",        pod.type("NA"))
    mapScalar("ph::Remove",    pod.type("Remove"))
    mapScalar("ph::Coord",     pod.type("Coord"))
    mapScalar("ph::XStr",      pod.type("XStr"))
    mapScalar("ph::Symbol",    pod.type("Symbol"))

    pod = Pod.find("graphics")
    mapScalar("ion.ui::Color",       pod.type("Color"))
    mapScalar("ion.ui::FontStyle",   pod.type("FontStyle"))
    mapScalar("ion.ui::FontWeight",  pod.type("FontWeight"))
    mapScalar("ion.ui::Insets",      pod.type("Insets"))
    mapScalar("ion.ui::Point",       pod.type("Point"))
    mapScalar("ion.ui::Size",        pod.type("Size"))
    mapScalar("ion.ui::Stroke",      pod.type("Stroke"))
  }

  private Void mapScalar(Str xeto, Type fantom)
  {
    x := XetoScalarType(xeto, fantom)
    fromXeto.add(x.xeto, x)
    fromFantom.add(x.fantom, x)
  }

  Str:XetoScalarType fromXeto := [:]
  Type:XetoScalarType fromFantom := [:]
}

**************************************************************************
** XetoScalarType
**************************************************************************

@Js
internal const class XetoScalarType
{
  new make(Str xeto, Type fantom)
  {
    this.xeto   = xeto
    this.fantom = fantom
    this.isStr  = xeto == "sys::Str"
  }

  const Str xeto
  const Type fantom
  const Bool isStr
}