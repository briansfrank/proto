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
    verifyGridRead(g, "text/csv", CsvWriter.gridToStr(g))
  }

  Void verifyGridRead(Grid g, Str mime, Str data)
  {
echo
echo("==== $mime")
echo(data)
    file := Buf().print(data).toFile(`foo.zinc`)
    set := env.read(data.in, MimeType(mime))
echo
set.dump
  }

  DataEnv env() { DataEnv.cur }
}