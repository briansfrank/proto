//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Mar 2023  Brian Frank  Creation
//

using util
using data2

**
** AST dict object
**
@Js
internal abstract class ADict : AVal
{
  ** Constructor
  new make(FileLoc loc)
  {
    this.loc = loc
  }

  ** Source code location
  const override FileLoc loc

  ** Map of the name/value pairs
  AMap map := AMap()

  ** Assembled value - raise exception if not assembled yet
  override Obj? asmVal() { asm ?: throw Err("Not assembled") }

  ** Assembled value handled in Assemble step
  DataDict? asm

  ** Return quoted string encoding
  override Str toStr() { "{" + map.toStr + "}" }

}