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
internal class AScalar : ANode
{
  ** Constructor
  new make(FileLoc loc, Str str, Obj? val := null)
  {
    this.loc = loc
    this.str = str
    this.val = val
  }

  ** Node type
  override ANodeType nodeType() { ANodeType.scalar }

  ** Source code location
  const override FileLoc loc

  ** Encoded string
  const Str str

  ** Is this scalar value already parsed into its final value
  Bool isAsm() { val != null }

  ** Assembled value - raise exception if not assembled yet
  override Obj asm() { val ?: throw NotAssembledErr() }

  ** Assembled value either passed in constructor or parsed in Assemble
  Obj? val

  ** Walk myself
  override Void walk(|ANode| f) { f(this) }

  ** Return quoted string encoding
  override Str toStr() { str.toCode }
}

