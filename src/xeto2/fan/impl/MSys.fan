//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Feb 2023  Brian Frank  Creation
//

using util
using data2

**
** Sys library constants
**
@Js
internal const class MSys
{
  new make(MLib lib)
  {
    this.obj      = lib.get("Obj")
    this.none     = lib.get("None")
    this.seq      = lib.get("Seq")
    this.dict     = lib.get("Dict")
    this.list     = lib.get("List")
    this.dataset  = lib.get("DataSet")
    this.lib      = lib.get("Lib")
    this.type     = lib.get("Type")
    this.slot     = lib.get("Slot")
    this.scalar   = lib.get("Scalar")
    this.marker   = lib.get("Marker")
    this.bool     = lib.get("Bool")
    this.str      = lib.get("Str")
    this.uri      = lib.get("Uri")
    this.number   = lib.get("Number")
    this.int      = lib.get("Int")
    this.float    = lib.get("Float")
    this.duration = lib.get("Duration")
    this.date     = lib.get("Date")
    this.time     = lib.get("Time")
    this.dateTime = lib.get("DateTime")
    this.ref      = lib.get("Ref")
    this.func     = lib.get("Func")
    this.maybe    = lib.get("Maybe")
    this.and      = lib.get("And")
    this.or       = lib.get("Or")
    this.query    = lib.get("Query")
  }

  const MSpec obj
  const MSpec none
  const MSpec dict
  const MSpec seq
  const MSpec list
  const MSpec dataset
  const MSpec lib
  const MSpec type
  const MSpec slot
  const MSpec scalar
  const MSpec marker
  const MSpec bool
  const MSpec str
  const MSpec uri
  const MSpec number
  const MSpec int
  const MSpec float
  const MSpec duration
  const MSpec date
  const MSpec time
  const MSpec dateTime
  const MSpec ref
  const MSpec func
  const MSpec maybe
  const MSpec and
  const MSpec or
  const MSpec query
}