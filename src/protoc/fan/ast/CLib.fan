//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using concurrent

**
** AST library
**
internal class CLib
{
  new make(Str name, File dir, File[] src)
  {
    this.loc  = Loc(dir)
    this.name = name
    this.dir  = dir
    this.src  = src
  }

  const Str name      // library name
  const Loc loc       // location of directory
  const File dir      // directory which contains lib.pog
  const File[] src    // pog files (first is always lib.pog)
}

