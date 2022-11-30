//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Nov 2022  Brian Frank  Creation
//

using pog
using haystack

**
** Prototype tree path as list of dotted names
**
@Js
const class HaystackPogIO : PogIO
{
  new make() : super("haystack") {}

  override Str summary()
  {
    "Adaptor for Haystack dict instances"
  }

  override Bool canRead(Obj input)
  {
    input is Grid || input is Dict
  }

  override Graph read(Obj input)
  {
    if (input is Dict) return read(Etc.makeDictGrid(null, input))
    grid := input as Grid ?: throw UnsupportedErr("Input not supported: $input [$input.typeof]")
echo("READ GRID")
grid.dump
throw Err("TODO")
  }

  override Bool canWrite(Obj? output)
  {
    output == null
  }

  override Obj? write(Graph graph, Obj? output := null)
  {
    if (output != null) throw UnsupportedErr("Output type must be null")
throw Err("TODO")
  }
}

