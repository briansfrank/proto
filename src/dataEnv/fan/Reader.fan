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
** Reader is base class to read different formats into memory as a DataSet
**
@Js
internal abstract class Reader
{
  static Reader factory(MDataEnv env, MimeType type, FileLoc loc, DataDict? opts)
  {
    type = type.noParams
    if (opts == null) opts = env.emptyDict
    if (loc.isUnknown) loc = opts["loc"] as FileLoc ?: FileLoc.unknown

    switch (type.noParams.toStr)
    {
      case "text/pog": return PogReader(env, loc, opts)
      default:         throw ArgErr("No reader for mime type: $type")
    }
  }

  new make(MDataEnv env, FileLoc loc, DataDict opts)
  {
    this.env =  env
    this.loc  = loc
    this.opts = opts
  }

  DataSet read(InStream in)
  {
    try
    {
      return onRead(in)
    }
    finally
    {
      try { in.close } catch (Err e) {}
    }
  }

  abstract DataSet onRead(InStream in)

  const MDataEnv env
  const FileLoc loc
  const DataDict opts
}

**************************************************************************
** PogReader
**************************************************************************

@Js
internal class PogReader : Reader
{
  new make(MDataEnv env, FileLoc loc, DataDict opts) : super(env, loc, opts) {}

  override DataSet onRead(InStream in)
  {
    arg := PogEnv.cur.data(in, ["data"], loc)
    proto := PogEnv.cur.transduce("compile", ["it":arg]).getProto
    return MDataSet.factory(env, proto)
  }

}

