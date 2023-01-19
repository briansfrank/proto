//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jan 2023  Brian Frank  Creation
//

using data
using dataEnv
using haystack

**
** HaystackDataReader for reading haystack grids to data sets
**
@Js
internal abstract class HaystackDataReader : DataReader
{
  new make(DataDict opts) : super(opts) {}

  override DataSet onReadSet(InStream in)
  {
    grid := readGrid(in)
    type := env.type("sys.Dict") // TODO
    rows := grid.mapToList |row->HDataDict| { HDataDict(type, row) }
    return env.set(rows)
  }

  abstract Grid readGrid(InStream in)
}

**************************************************************************
** ZincDataReader
**************************************************************************

@Js
internal class ZincDataReader : HaystackDataReader
{
  new make(DataDict opts) : super(opts) {}
  override Grid readGrid(InStream in) { ZincReader(in).readGrid }
}

**************************************************************************
** JsonDataReader
**************************************************************************

@Js
internal class JsonDataReader : HaystackDataReader
{
  new make(DataDict opts) : super(opts) {}
  override Grid readGrid(InStream in) { JsonReader(in).readGrid }
}


**************************************************************************
** TrioDataReader
**************************************************************************

@Js
internal class TrioDataReader : HaystackDataReader
{
  new make(DataDict opts) : super(opts) {}
  override Grid readGrid(InStream in) { TrioReader(in).readGrid }
}

**************************************************************************
** CsvDataReader
**************************************************************************

@Js
internal class CsvDataReader : HaystackDataReader
{
  new make(DataDict opts) : super(opts) {}
  override Grid readGrid(InStream in) { CsvReader(in).readGrid }
}

