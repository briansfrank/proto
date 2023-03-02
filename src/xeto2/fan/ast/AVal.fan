//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Mar 2023  Brian Frank  Creation
//

using util

**
** AST value that is assembled into a reflection API dict value.
**
@Js
internal abstract class AVal
{

  ** Source code location
  abstract FileLoc loc()

  ** Assembled value - raise exception if not assembled yet
  abstract Obj? asmVal()

}