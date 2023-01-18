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

  ** List the library qnames installed by this environment
  abstract Str[] installed()

  ** Load the given library qualified name
  abstract DataLib? load(Str qname, Bool checked := true)

  ** Create DataDict from a map of raw data values
  abstract DataDict dict(Str:Obj? map, DataType? type := null)

  ** Create DataSet from a list or map of data dict records
  abstract DataSet set(Obj recs)

}