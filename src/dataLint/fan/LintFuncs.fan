//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jan 2023  Brian Frank  Creation
//

using data
using haystackx
using axonx

**
** Axon functions for linting
**
@Js
const class LintFuncs
{
  **
  ** Return grid which explains how data fits the given type.  This
  ** function takes one or more recs and returns a grid.  For each rec
  ** zero or more rows are returned with an error why the rec does not
  ** fit the given type.  If a rec does fit the type, then zero rows are
  ** returned for that record.
  **
  ** Example:
  **    readAll(vav and hotWaterHeating).lintFit(G36ReheatVav)
  **
  @Axon
  static Grid lintFits(Obj? recs, DataType type)
  {
    Linter(AxonContext.curAxon).lintFits(recs, type)
  }
}


