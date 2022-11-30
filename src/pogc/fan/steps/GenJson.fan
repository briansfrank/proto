//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Aug 2022  Brian Frank  Creation
//

using pog

**
** Generate a JSON file for the proto space
**
internal class GenJson : Step
{
  override Void run()
  {
    file := compiler.outDir + `protos.json`

    env.io.write("json-ast", graph, file)

    info("generated JSON [$file.osPath]")
  }
}