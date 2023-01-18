//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using concurrent
using data
using pog

**
** DataEnv implementation
**
@Js
internal const class MDataEnv : DataEnv
{
  new make()
  {
    this.sys = MSys(load("sys"))
  }

  const MSys sys

  override Str[] installed() { PogEnv.cur.installed }

  override DataLib? load(Str qname, Bool checked := true)
  {
    lib := libs.get(qname)
    if (lib == null) lib = libs.getOrAdd(qname, MDataLib(this, qname))
    return lib
  }

  override DataDict dict(Str:Obj? map, DataType? type := null)
  {
    MDataDict(map, type)
  }

  override DataSet set(Obj recs)
  {
    MDataSet.factory(this, recs)
  }

  private const ConcurrentMap libs := ConcurrentMap()
}

**************************************************************************
** MSys
**************************************************************************

@Js
internal const class MSys
{
  new make(MDataLib lib)
  {
    this.lib     = lib
    this.obj     = lib.type("Obj")
    this.dict    = lib.type("Dict")
    this.libType = lib.type("Lib")
  }

  const DataLib lib
  const DataType obj
  const DataType dict
  const DataType libType
}


