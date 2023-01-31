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

  **
  ** Find all types which fit that given recs.  In the case of inheritance
  ** the most specific type is returned.  Types that are marked as 'abstract'
  ** are not returned.
  **
  ** Example:
  **    readAll(vav).lintFindAllFits
  **
  @Axon
  static Grid lintFindAllFits(Obj? recs)
  {
    // collect all dict, non-abstract data types in scope
    cx := AxonContext.curAxon
    allTypes := Str:DataType[:]
    cx.dataLibs.each |lib|
    {
      lib.libTypes.each |x|
      {
        if (!x.isaDict) return
        if (x.meta.has("abstract")) return
        if (x.lib.qname == "sys") return
        allTypes[x.qname] = x
      }
    }

    // walk thru each record add row
    gb := GridBuilder().addCol("lintRef").addCol("num").addCol("types")
    fitter := Fitter(cx)
    Etc.toRecs(recs).each |rec|
    {
      matches := fitter.matchAll(rec, allTypes)
      gb.addRow([rec.id, Number(matches.size), matches])
    }
    return gb.toGrid
  }

}


