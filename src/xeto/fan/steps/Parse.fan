//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using util

**
** Parse all source files into AST nodes
**
internal class Parse : Step
{
  override Void run()
  {
   echo("#### parse!")
    bombIfErr
  }

}