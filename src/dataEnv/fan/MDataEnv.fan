//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
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
    this.sys = MSys(lib("sys"))
    this.emptyDict = MEmptyDict(sys.dict)
  }

  const MSys sys

  override DataObj obj(Obj val)
  {
    // hard code mapping to get us started with this API
    if (val is DataObj)  return val
    if (val is Str)      return MDataScalar(sys.str, val)
    if (val is Bool)     return MDataScalar(sys.bool, val)
    if (val is Int)      return MDataScalar(sys.int, val)
    if (val is Float)    return MDataScalar(sys.float, val)
    if (val is Duration) return MDataScalar(sys.duration, val)
    if (val is Date)     return MDataScalar(sys.date, val)
    if (val is Time)     return MDataScalar(sys.time, val)
    if (val is DateTime) return MDataScalar(sys.dateTime, val)
    if (val is Uri)      return MDataScalar(sys.uri, val)
    if (val is Map)      return dict(val)
    return MDataScalar(sys.str, val.toStr)
  }

  const override DataDict emptyDict

  override DataDict dict(Str:Obj map, DataType? type := null)
  {
    if (type == null) type = sys.dict
    if (map.isEmpty) return type === sys.dict ? emptyDict : MEmptyDict(type)
    return MMapDict(type, map)
  }

  override DataDict dictSet(DataDict? dict, Str name, Obj val)
  {
    map := Str:Obj[:]
    if (dict != null) dict.each |v, n| { map[n] = v }
    map[name] = val
    return this.dict(map, dict?.type)
  }

  override DataSet set(Obj recs)
  {
    MDataSet.factory(this, recs)
  }

  override DataSet read(InStream in, MimeType type, DataDict? opts := null)
  {
    reader := DataReader.factory(this, type, opts ?: emptyDict)
    return reader.readSet(in)
  }

  override DataSet readFile(File file, DataDict? opts := null)
  {
    type := file.mimeType ?: throw ArgErr("Cannot determine mime type from file ext: $file.name")
    opts = dictSet(opts, "loc", FileLoc(file))
    reader := DataReader.factory(this, type, opts)
    return reader.readSet(file.in)
  }

  override Str[] installed() { PogEnv.cur.installed }

  override DataLib? lib(Str qname, Bool checked := true)
  {
try
{
    lib := libs.get(qname)
    if (lib == null) lib = libs.getOrAdd(qname, MDataLib(this, qname))
    return lib
}
catch (pog::UnknownLibErr e)
{
  if (checked) throw data::UnknownLibErr(qname)
  return null
}
  }

  override DataType? type(Str qname, Bool checked := true)
  {
    dot := qname.indexr(".") ?: throw ArgErr("Invalid qname: qname")
    libName := qname[0..<dot]
    typeName := qname[dot+1..-1]
    return lib(libName, checked)?.type(typeName, checked)
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
    this.lib      = lib
    this.obj      = lib.type("Obj")
    this.dict     = lib.type("Dict")
    this.libType  = lib.type("Lib")
    this.bool     = lib.type("Bool")
    this.str      = lib.type("Str")
    this.uri      = lib.type("Uri")
    this.int      = lib.type("Int")
    this.float    = lib.type("Float")
    this.duration = lib.type("Duration")
    this.date     = lib.type("Date")
    this.time     = lib.type("Time")
    this.dateTime = lib.type("DateTime")
  }

  const DataLib lib
  const DataType obj
  const DataType dict
  const DataType libType
  const DataType bool
  const DataType str
  const DataType uri
  const DataType int
  const DataType float
  const DataType duration
  const DataType date
  const DataType time
  const DataType dateTime
}


