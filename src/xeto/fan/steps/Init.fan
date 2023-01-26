//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Jan 2023  Brian Frank  Creation
//

using util

**
** Initialize lib compile
**
@Js
internal class InitLib : Step
{
  override Void run()
  {
    // set the flag for compiling lib
    compiler.isLib = true

    // check input is directory
    input := compiler.input
    if (input == null) throw err("Compiler input not configured", FileLoc.inputs)
    if (!input.exists) throw err("Input file not found: $input", FileLoc.inputs)
    if (!input.isDir) throw err("Lib input must be directory: $input", FileLoc.inputs)

    // default qname to directory
    if (compiler.qname == null)
      compiler.qname = input.name
  }
}