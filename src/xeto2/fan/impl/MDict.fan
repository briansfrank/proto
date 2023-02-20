//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Feb 2023  Brian Frank  Creation (yet again)
//

using util
using data2

**
** Implementation of DataDict
**
@Js
internal const class MDict : DataDict
{
  new make(Str:Obj map) { this.map = map }

  const Str:Obj map

  override DataSpec spec()
  {
    throw Err("TODO")
  }

  override Bool isEmpty()
  {
    map.isEmpty
  }

  @Operator override Obj? get(Str name, Obj? def := null)
  {
    map.get(name, def)
  }

  override Bool has(Str name)
  {
    map.get(name) != null
  }

  override Bool missing(Str name)
  {
    map.get(name) == null
  }

  override Void each(|Obj val, Str name| f)
  {
    map.each(f)
  }

  override Obj? eachWhile(|Obj val, Str name->Obj?| f)
  {
    map.eachWhile(f)
  }

  override Obj? trap(Str name, Obj?[]? args := null)
  {
    x := map.get(name, null)
    if (x != null) return x
    throw UnknownDataErr(name)
  }

}