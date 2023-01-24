//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jan 2023  Brian Frank  Creation
//

using data
using dataEnv
using haystackx

**
** HDataDict wraps haystack::Dict as a DataDict
**
@Js
internal const class HDataDict : DataDict, Dict
{
  new make(DataType type, Dict dict)
  {
    this.type = type
    this.dict = dict
  }

  const override DataType type

  const Dict dict

  override Bool isEmpty() { dict.isEmpty }

  override Bool has(Str name) { dict.has(name) }

  override Bool missing(Str name) { dict.missing(name) }

  override Obj? get(Str name, Obj? def := null) { dict.get(name, def) }

  override Obj? trap(Str n, Obj?[]? a := null) { dict.trap(n, a) }

  override DataDictX x() { MDataDictX(this) }

  override Void each(|Obj?,Str| f) { dict.each(f) }

  override Obj? eachWhile(|Obj?,Str->Obj?| f) { dict.eachWhile(f) }

  override Str toStr() { dict.toStr }

}


