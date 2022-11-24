//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent
using util

**
** Named reference to a proto
**
internal class CType
{
  new makeMaybe(CType of)
  {
    this.loc  = of.loc
    this.name = "sys.Maybe"
    this.of   = [of]
  }

  new makeOr(CType[] of)
  {
    this.loc  = of[0].loc
    this.name = "sys.Or"
    this.of   = of
  }

  new makeAnd(CType[] of)
  {
    this.loc  = of[0].loc
    this.name = "sys.And"
    this.of   = of
  }

  new makeUnresolved(FileLoc loc, Str name, Str? val := null)
  {
    this.loc  = loc
    this.name = name
    this.val  = val
  }

  new makeResolved(FileLoc loc, CProto c)
  {
    this.loc = loc
    this.name = c.name
    this.resolved = c
  }

  const FileLoc loc
  const Str name       // simple or dotted qname
  const Str? val       // if value type
  CType[]? of          //  if compound and/or/maybe type

  Bool isResolved() { resolved != null }

  CProto deref() { resolved ?: throw Err("Not resolved yet: $name") }

  CProto? get(Str name)
  {
    if (of == null) return deref.get(name, false)
    return of.eachWhile |x| { x.get(name) }
  }

  override Str toStr() { name }

  CProto? resolved  // Resolve step
}

