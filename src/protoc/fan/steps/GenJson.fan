//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Aug 2022  Brian Frank  Creation
//

using proto

**
** Generate a JSON file for the proto space
**
internal class GenJson : Step
{
  override Void run()
  {
    file := compiler.outDir + `protos.json`

    JsonProtoEncoder(file.out).encode(ps).close

    info("generated JSON [$file.osPath]")
  }
}