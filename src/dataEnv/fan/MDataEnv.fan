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

  const override DataDict emptyDict

  override DataDict dict(Str:Obj? map, DataType? type := null)
  {
    MDataDict(map, type)
  }

  override DataSet set(Obj recs)
  {
    MDataSet.factory(this, recs)
  }

  override DataSet read(InStream in, MimeType type, DataDict? opts := null)
  {
    reader := Reader.factory(this, type, FileLoc.unknown, opts)
    return reader.read(in)
  }

  override DataSet readFile(File file, DataDict? opts := null)
  {
    type := file.mimeType ?: throw ArgErr("Cannot determine mime type from file ext: $file.name")
    reader := Reader.factory(this, type, FileLoc(file), opts)
    return reader.read(file.in)
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


