//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto
using util

**
** Pragma from a single source file
**
internal class CPragma
{
  new make(FileLoc loc, CLib lib) { this.loc = loc; this.lib = lib  }

  const FileLoc loc
  CLib lib

  Str:CProto[] cache := Str:CProto[][:]
}

