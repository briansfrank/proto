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
    x := lib.slotsOwn
    this.obj      = x.get("Obj")
    this.none     = x.get("None")
    this.seq      = x.get("Seq")
    this.dict     = x.get("Dict")
    this.list     = x.get("List")
    this.dataset  = x.get("DataSet")
    this.lib      = x.get("Lib")
    this.spec     = x.get("Spec")
    this.type     = x.get("Type")
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
    this.maybe    = x.get("Maybe")
    this.and      = x.get("And")
    this.or       = x.get("Or")
    this.query    = x.get("Query")
  }

  const MType obj
  const MType none
  const MType dict
  const MType seq
  const MType list
  const MType dataset
  const MType lib
  const MType spec
  const MType type
  const MType scalar
  const MType marker
  const MType bool
  const MType str
  const MType uri
  const MType number
  const MType int
  const MType float
  const MType duration
  const MType date
  const MType time
  const MType dateTime
  const MType ref
  const MType maybe
  const MType and
  const MType or
  const MType query
}