//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
using data
using pog

**
** MDataDef base class
**
@Js
internal const abstract class MDataDef : DataDef
{
  abstract override MDataEnv env()

  abstract override MDataLib lib()

  abstract Str:DataDict map()

  override final This val() { this }

  override final Bool isEmpty() { map.isEmpty }

  override final Bool has(Str name) { map.get(name, null) != null }

  override final Bool missing(Str name) { map.get(name, null) == null }

  override final Obj? get(Str name, Obj? def := null) { map.get(name, def) }

  override final Obj? trap(Str n, Obj?[]? a := null) { MDataUtil.dictTrap(this, n) }

  override final DataObj? getData(Str name, Bool checked := true) { MDataUtil.dictGetData(this, name, checked) }

  override final Void each(|Obj?,Str| f) { map.each(f) }

  override final Obj? eachWhile(|Obj?,Str->Obj?| f) { map.eachWhile(f) }

  override final Void eachData(|DataObj,Str| f) { MDataUtil.dictEachData(this, f) }

  override final Str doc() { meta["doc"] as Str ?: "" }

  override final Str toStr() { qname }

}

