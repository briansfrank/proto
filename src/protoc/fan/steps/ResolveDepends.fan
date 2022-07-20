//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jul 2022  Brian Frank  Creation
//

using proto

**
** ResolveDepends resolves each lib's dependencies
**
internal class ResolveDepends : Step
{
  override Void run()
  {
    libs.each |lib| { resolveLib(lib) }
    bombIfErr
  }

  Void resolveLib(CLib lib)
  {
    // TODO - just include sys in all libs for now
    if (lib.isSys)
      lib.depends = CLib[,]
    else
      lib.depends = CLib[libs.find  { it.isSys }]
  }
}

