//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2023  Brian Frank  Creation
//

using data2

**
** Implementation of DataSlots
**
@Js
internal const class MSlots : DataSlots
{
  new make(Str:MSpec map) { this.map = map }

  const Str:MSpec map

  override Bool isEmpty()
  {
    map.isEmpty
  }

  override MSpec? get(Str name, Bool checked := true)
  {
    kid := map[name]
    if (kid != null) return kid
    if (!checked) return null
    throw UnknownSpecErr(name)
  }

  override Void each(|DataSpec,Str| f)
  {
    map.each(f)
  }

  override Obj? eachWhile(|DataSpec,Str->Obj?| f)
  {
    map.eachWhile(f)
  }

  override Str toStr()
  {
    s := StrBuf()
    s.add("{")
    each |spec, name|
    {
      if (s.size > 1) s.add(", ")
      s.add(name)
    }
    return s.add("}").toStr
  }

}