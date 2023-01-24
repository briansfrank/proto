//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jan 2023  Brian Frank  Creation
//

using util
using data
using pog

**
** DataReader is base class to read different formats into memory as a DataSet
**
@Js
abstract class DataReader
{
  internal static DataReader factory(MDataEnv env, MimeType type, DataDict opts)
  {
    // just hardcoded for now
    type = type.noParams
    switch (type.noParams.toStr)
    {
      case "text/pog":         return PogReader(opts)
      case "text/zinc":        return Type.find("dataHaystack::ZincDataReader").make([opts])
      case "application/json": return Type.find("dataHaystack::JsonDataReader").make([opts])
      case "text/trio":        return Type.find("dataHaystack::TrioDataReader").make([opts])
      case "text/csv":         return Type.find("dataHaystack::CsvDataReader").make([opts])
      default:                 throw ArgErr("No reader for mime type: $type")
    }
  }

  new make(DataDict opts)
  {
    this.env =  opts.type.env
    this.opts = opts
    this.loc  = opts["loc"] as FileLoc ?: FileLoc.unknown
  }

  DataSet readSet(InStream in)
  {
    try
    {
      return onReadSet(in)
    }
    finally
    {
      try { in.close } catch (Err e) {}
    }
  }

  abstract DataSet onReadSet(InStream in)

  const DataEnv env
  const DataDict opts
  const FileLoc loc
}

**************************************************************************
** PogReader
**************************************************************************

@Js
internal class PogReader : DataReader
{
  new make(DataDict opts) : super(opts) {}

  override DataSet onReadSet(InStream in)
  {
    throw Err("TODO")
    /*
    arg := PogEnv.cur.data(in, ["data"], loc)
    proto := PogEnv.cur.transduce("compile", ["it":arg]).getProto
    return MDataSet.factory(env, proto)
    */
  }

}

