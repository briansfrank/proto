//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Feb 2023  Brian Frank  Creation
//

using util

**
** AST object reference to a named DataSpec
**
@Js
internal class ARef : ANode
{
  ** Constructor
  new make(FileLoc loc, AName name)
  {
    this.loc = loc
    this.name = name
  }

  ** Node type
  override ANodeType nodeType() { ANodeType.ref }

  ** Source code location
  const override FileLoc loc

  ** Qualified/unqualified name
  const AName name

  ** Resolved reference or raise UnresolvedErr
  override XetoSpec asm() { referent ?: throw UnresolvedErr("$name [$loc]") }

  ** Resolved reference
  XetoSpec? referent

  ** Is this reference already resolved
  Bool isResolved() { referent != null }

  ** Walk myself
  override Void walk(|ANode| f) { f(this) }

  ** Return qualified/unqualified name
  override Str toStr() { name.toStr }

}