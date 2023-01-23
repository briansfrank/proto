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

  const Str:DataDict emptyMap := [:]

  override DataType? typeOf(Obj? val, Bool checked := true)
  {
    // TODO hard code mapping to get us started with this API
    if (val == null) return sys.none
    if (val is DataDict) return ((DataDict)val).type
    if (val is Str)      return sys.str
    if (val is Bool)     return sys.bool
    if (val is Int)      return sys.int
    if (val is Float)    return sys.float
    if (val is Duration) return sys.duration
    if (val is Date)     return sys.date
    if (val is Time)     return sys.time
    if (val is DateTime) return sys.dateTime
    if (val is Uri)      return sys.uri

    // TODO
    qname := val.typeof.qname
    switch (qname)
    {
      case "haystack::Marker": return sys.marker
      case "haystack::Number": return sys.number
      case "haystack::Ref":    return sys.ref
    }

    if (checked) throw UnknownTypeErr("No DataType mapped for '$val.typeof'")
    return null
  }

  override Bool fits(Obj? val, DataType type)
  {
    MFitter(this).fits(val, type)
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

  override DataSeq seq(Obj? val)
  {
    if (val == null) return emptyDict
    if (val is DataSeq) return val
    if (val is List) return MDataList(sys.list, val)
    if (val is Map)
    {
      keyType := val.typeof.params["K"]
      if (keyType == Str#) return dict(val)
      return MDataList(sys.list, ((Map)val).vals)
    }
    throw Err("TODO")
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
    return lib(libName, checked)?.libType(typeName, checked)
  }

  override DataFunc? func(Str qname, Bool checked := true)
  {
    func := type(qname, false) as DataFunc
    if (func != null) return func
    if (checked) throw UnknownFuncErr(qname)
    return null
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
    this.obj      = lib.libType("Obj")
    this.none     = lib.libType("None")
    this.dict     = lib.libType("Dict")
    this.list     = lib.libType("List")
    this.libType  = lib.libType("Lib")
    this.type     = lib.libType("Type")
    this.slot     = lib.libType("Slot")
    this.marker   = lib.libType("Marker")
    this.bool     = lib.libType("Bool")
    this.str      = lib.libType("Str")
    this.uri      = lib.libType("Uri")
    this.number   = lib.libType("Number")
    this.int      = lib.libType("Int")
    this.float    = lib.libType("Float")
    this.duration = lib.libType("Duration")
    this.date     = lib.libType("Date")
    this.time     = lib.libType("Time")
    this.dateTime = lib.libType("DateTime")
    this.ref      = lib.libType("Ref")
    this.func     = lib.libType("Func")
  }

  const DataLib lib
  const DataType obj
  const DataType none
  const DataType dict
  const DataType list
  const DataType libType
  const DataType type
  const DataType slot
  const DataType marker
  const DataType bool
  const DataType str
  const DataType uri
  const DataType number
  const DataType int
  const DataType float
  const DataType duration
  const DataType date
  const DataType time
  const DataType dateTime
  const DataType ref
  const DataType func
}


