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
    x := lib.declared
    this.obj      = x.get("Obj")
    this.none     = x.get("None")
    this.seq      = x.get("Seq")
    this.dict     = x.get("Dict")
    this.list     = x.get("List")
    this.dataset  = x.get("DataSet")
    this.lib      = x.get("Lib")
    this.type     = x.get("Type")
    this.slot     = x.get("Slot")
    this.scalar   = x.get("Scalar")
    this.marker   = x.get("Marker")
    this.bool     = x.get("Bool")
    this.str      = x.get("Str")
    this.uri      = x.get("Uri")
    this.number   = x.get("Number")
    this.int      = x.get("Int")
    this.float    = x.get("Float")
    this.duration = x.get("Duration")
    this.date     = x.get("Date")
    this.time     = x.get("Time")
    this.dateTime = x.get("DateTime")
    this.ref      = x.get("Ref")
    this.func     = x.get("Func")
    this.maybe    = x.get("Maybe")
    this.and      = x.get("And")
    this.or       = x.get("Or")
    this.query    = x.get("Query")
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