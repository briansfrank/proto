//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util

**
** Environment for the data processing subsystem.
** There is one instance for the VM accessed via `DataEnv.cur`.
**
@Js
const abstract class DataEnv
{
  ** Current default environment for the VM
  static DataEnv cur() { curRef ?: throw Err("DataEnv not initialized") }

  // init env instance using reflection
  private static const DataEnv? curRef
  static
  {
    try
    {
      curRef = Type.find("dataEnv::MDataEnv").make
    }
    catch (Err e)
    {
      echo("ERROR: cannot init DataEnv.cur")
      e.trace
    }
  }

  ** Map fantom object to its DataObj representation
  abstract DataObj obj(Obj val)

  ** Empty dict
  abstract DataDict emptyDict()

  ** Create DataDict from a map of raw data values
  abstract DataDict dict(Str:Obj? map, DataType? type := null)

  ** Create DataSet from a list or map of data dict records
  abstract DataSet set(Obj recs)

  ** Read a data into memory from input stream based on given
  ** format type. The stream is guaranteed to be closed.
  abstract DataSet read(InStream in, MimeType type, DataDict? opts := null)

  ** Read data set into memory from a file.
  ** Format type is determined by the file's extension.
  abstract DataSet readFile(File file, DataDict? opts := null)

  ** List the library qnames installed by this environment
  abstract Str[] installed()

  ** Get or load library by the given qualified name
  abstract DataLib? lib(Str qname, Bool checked := true)

  ** Get or load type by the given qualified name
  abstract DataType? type(Str qname, Bool checked := true)

}