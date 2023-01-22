//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jan 2023  Brian Frank  Creation
//

using util
using data
using haystack

**
** HaystackDataTest
**
@Js
class HaystackDataTest : HaystackTest
{

//////////////////////////////////////////////////////////////////////////
// Grid
//////////////////////////////////////////////////////////////////////////

  Void testGrid()
  {
    gb := GridBuilder()
    gb.addCol("id").addCol("dis").addCol("site").addCol("geoCity")
    gb.addRow([Ref("a"), "A", m, "Richmond"])
    gb.addRow([Ref("b"), "B", m, "Norfolk"])
    g := gb.toGrid

    verifyGridRead(g, "text/zinc", ZincWriter.gridToStr(g))
    verifyGridRead(g, "application/json", JsonWriter.valToStr(g))
    verifyGridRead(g, "text/trio", TrioWriter.gridToStr(g))
    verifyGridRead(CsvReader(CsvWriter.gridToStr(g).in).readGrid, "text/csv", CsvWriter.gridToStr(g))
  }

  Void verifyGridRead(Grid grid, Str mime, Str data)
  {
    file := Buf().print(data).toFile(`foo.zinc`)
    set := env.read(data.in, MimeType(mime))
    verifyEq(set.size, grid.size)
    i := 0
    set.each |rec|
    {
      verifyDataDict(rec, grid[i++])
    }
  }

  Void verifyDataDict(DataDict a, Dict b)
  {
    verifyEq(a.type.qname, "sys.Dict")

    a.each |v, n| { verifyEq(v, b[n]) }
    b.each |v, n| { verifyEq(v, a[n]) }

    /* TODO
    a.eachData |x, n|
    {
      verifySame(a.getData(n).type, x.type)
      verifyEq(x.type.name, Kind.fromVal(b[n]).name)
    }
    */
  }

  DataEnv env() { DataEnv.cur }
}