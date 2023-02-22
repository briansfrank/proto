//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Feb 2023  Brian Frank  Creation
//

using concurrent
using util

**
** AST object reference
**
@Js
internal class ARef
{
  new make(FileLoc loc, Str name)
  {
    this.loc = loc
    this.name = name
  }

  override Str toStr() { name }

  const FileLoc loc
  const Str name       // relative or qualified

  Bool isResolved() { resolvedRef != null }

  AtomicRef resolved() { resolvedRef ?: throw Err("Unresolved: $name [$loc]") }

  AtomicRef? resolvedRef

}