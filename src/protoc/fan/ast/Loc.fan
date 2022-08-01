//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent

**
** AST source code location
**
const class Loc
{
  ** None or unknown location
  static const Loc none := make("unknown", 0)

  ** Compiler inputs
  static const Loc inputs := make("inputs", 0)

  ** Compiler synthetic protos
  static const Loc synthetic := make("synthetic", 0)

  ** Constructor for file
  static new makeFile(File file)
  {
    uri := file.uri
    name := uri.scheme == "fan" ? "$uri.host::$uri.pathStr" : file.pathStr
    return make(name)
  }

  ** Constructor for file and line
  new make(Str file, Int line := 0)
  {
    this.file = file
    this.line = line
  }

  ** Filename location
  const Str file

  ** Line number or zero if unknown
  const Int line

  ** Return string representation
  override Str toStr()
  {
    if (line <= 0) return file
    return "$file($line)"
  }

}



