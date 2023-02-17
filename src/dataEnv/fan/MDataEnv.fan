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
using xeto

**
** DataEnv implementation
**
@Js
internal const class MDataEnv : DataEnv
{
  new make()
  {
    this.libMgr = MLibMgr(this)
    this.sys = MSys(lib("sys"))
    this.emptyDict = MEmptyDict(sys.dict)
    this.emptySet  = MDataSet(sys.dataset, Dict#.emptyList)
  }

  const MLibMgr libMgr

  const MSys sys

  const Str:Dict emptyDictMap := [:]

  const override Dict emptyDict

  const override DataSet emptySet

  override DataType? typeOf(Obj? val, Bool checked := true)
  {
    // TODO hard code mapping to get us started with this API
    if (val == null) return sys.none
    if (val is DataSeq)  return ((DataSeq)val).type
    if (val is Str)      return sys.str
    if (val is Bool)     return sys.bool
    if (val is Int)      return sys.int
    if (val is Float)    return sys.float
    if (val is Duration) return sys.duration
    if (val is Date)     return sys.date
    if (val is Time)     return sys.time
    if (val is DateTime) return sys.dateTime
    if (val is Uri)      return sys.uri
    if (val is List)     return sys.list

    // TODO
    qname := val.typeof.qname
    switch (qname)
    {
      case "data::Marker": return sys.marker
      case "haystackx::Number": return sys.number
      case "haystackx::Ref":    return sys.ref
    }

    if (checked) throw UnknownTypeErr("No DataType mapped for '$val.typeof'")
    return null
  }

  override Dict dict(Obj? val)
  {
    if (val == null) return emptyDict
    if (val is Dict) return val
    map := val as Str:Obj? ?: throw ArgErr("Unsupported dict arg: $val.typeof")
    if (map.isEmpty) return emptyDict
    return MMapDict(sys.dict, map)
  }

  internal Dict astMeta(Str:XetoObj ast)
  {
    if (ast.isEmpty && (Obj?)emptyDict != null) return emptyDict
    acc := Str:Obj[:]
    ast.each |v, n|
    {
      // TODO
      if (v.val != null)
        acc[n] = v.val
      else if (v.type?.name == "sys.Marker")
        acc[n] = marker
      //else
      //  echo("TODO: map AST meta: $n: $v.type")
    }
    return MMapDict(null, acc)
  }

  internal Obj marker() { Marker.val }

  override DataSeq seq(Obj? val)
  {
    if (val == null) return emptyDict
    if (val is DataSeq) return val
    if (val is List) return MDataList(sys.list, val)
    if (val is Map)
    {
      map := (Map)val
      if (map.isEmpty) return emptyDict
      keyType := val.typeof.params["K"]
      if (keyType == Str#) return dict(val)
      return MDataList(sys.list, ((Map)val).vals)
    }
    return MDataList(sys.list, Obj?[val])
  }

  override DataSet set(Obj? val)
  {
    if (val == null) return emptySet
    if (val is DataSet) return val
    if (val is List)
    {
      list := (List)val
      if (list.isEmpty) return emptySet
      return MDataSet(sys.dataset, list)
    }
    throw ArgErr("Unsupported set arg: $val.typeof")
  }

  override Void print(Obj? val, OutStream out := Env.cur.out, Obj? opts := null)
  {
    Printer(out, dict(opts)).print(val)
  }

  override Str[] libsInstalled() { libMgr.installed }

  override Bool isLibLoaded(Str qname) { libMgr.isLoaded(qname) }

  override DataLib? lib(Str qname, Bool checked := true) { libMgr.load(qname, checked) }

  override DataType? type(Str qname, Bool checked := true)
  {
    dot := qname.indexr(".") ?: throw ArgErr("Invalid qname: $qname")
    libName := qname[0..<dot]
    typeName := qname[dot+1..-1]
    return lib(libName, checked)?.libType(typeName, checked)
  }

  override DataSlot? slot(Str qname, Bool checked := true)
  {
    dot := qname.indexr(".") ?: throw ArgErr("Invalid qname: $qname")
    typeName := qname[0..<dot]
    slotName := qname[dot+1..-1]
    return type(typeName)?.slot(slotName, checked)
  }

  override DataFunc? func(Str qname, Bool checked := true)
  {
    func := type(qname, false) as DataFunc
    if (func != null) return func
    if (checked) throw UnknownFuncErr(qname)
    return null
  }

  override Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("=== DataEnv ===")
    out.printLine("Lib Path:")
    libMgr.path.each |x| { out.printLine("  $x.osPath") }
    max := libsInstalled.reduce(10) |acc, x| { x.size.max(acc) }
    out.printLine("Installed Libs:")
    libMgr.installed.each |x| { out.printLine("  " + x.padr(max) + " [" + libMgr.libDir(x, true).osPath + "]") }
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
    this.seq      = lib.libType("Seq")
    this.dict     = lib.libType("Dict")
    this.list     = lib.libType("List")
    this.dataset  = lib.libType("DataSet")
    this.libType  = lib.libType("Lib")
    this.type     = lib.libType("Type")
    this.slot     = lib.libType("Slot")
    this.scalar   = lib.libType("Scalar")
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
    this.maybe    = lib.libType("Maybe")
    this.and      = lib.libType("And")
    this.or       = lib.libType("Or")
    this.query    = lib.libType("Query")
  }

  const DataLib lib
  const DataType obj
  const DataType none
  const DataType dict
  const DataType seq
  const DataType list
  const DataType dataset
  const DataType libType
  const DataType type
  const DataType slot
  const DataType scalar
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
  const DataType maybe
  const DataType and
  const DataType or
  const DataType query
}


