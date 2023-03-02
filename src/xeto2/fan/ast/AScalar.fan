//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Mar 2023  Brian Frank  Creation
//

using util

**
** AST scalar value
**
@Js
internal abstract class AScalar : AVal
{
  ** Constructor
  new make(FileLoc loc, Str str, Obj? asm := null)
  {
    this.loc = loc
    this.str = str
    this.asm = asm
  }

  ** Source code location
  const override FileLoc loc

  ** Encoded string
  const Str str

  ** Is this scalar value already assembled into its final value
  Bool isAsm() { asm != null }

  ** Assembled value - raise exception if not assembled yet
  override Obj? asmVal() { asm ?: throw Err("Not assembled") }

  ** Assembled value handled in Assemble step
  Obj? asm

  ** Return quoted string encoding
  override Str toStr() { str.toCode }
}