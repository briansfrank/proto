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

  ** Data type for Fantom object
  abstract DataType? typeOf(Obj? val, Bool checked := true)

  ** Return if objects fits given type either nominally or structurally
  abstract Bool fits(Obj? val, DataType type)

  ** Empty dict
  abstract DataDict emptyDict()

  ** Create DataDict from a map of raw data values
  abstract DataDict dict(Str:Obj map, DataType? type := null)

  ** Set name/value pair in given dict,.
  abstract DataDict dictSet(DataDict? dict, Str name, Obj val)

  ** Create a sequence object from given value:
  **   - If null, return the empty sequence
  **   - If DataSeq return it
  **   - If Fantom map with string keys, wrap it as DataDict
  **   - If Fantom map without string keys, wrap list of value as DataSeq
  **   - If Fantom list, wrap it as DataSeq
  **   - Anything else create sequence of one item from value
  abstract DataSeq seq(Obj? val)

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

  ** Get or load function type by the given qualified name
  abstract DataFunc? func(Str qname, Bool checked := true)

}