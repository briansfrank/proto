//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jan 2023  Brian Frank  Creation
//

using data
using dataEnv
using haystack

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

  override This val() { this }

  override Bool isEmpty() { dict.isEmpty }

  override Bool has(Str name) { dict.has(name) }

  override Bool missing(Str name) { dict.missing(name) }

  override Obj? get(Str name, Obj? def := null) { dict.get(name, def) }

  override Obj? trap(Str n, Obj?[]? a := null) { dict.trap(n, a) }

  override DataObj? getData(Str name, Bool checked := true) { MDataUtil.dictGetData(this, name, checked) }

  override Void each(|Obj?,Str| f) { dict.each(f) }

  override Obj? eachWhile(|Obj?,Str->Obj?| f) { dict.eachWhile(f) }

  override Void eachData(|DataObj,Str| f) { MDataUtil.dictEachData(this, f) }

  override Str toStr() { dict.toStr }

}


