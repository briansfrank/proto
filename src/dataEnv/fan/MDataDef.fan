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

**
** MDataDef base class
**
@Js
internal const abstract class MDataDef : MAbstractDict, DataDef
{
  abstract override MDataEnv env()

  abstract override MDataLib lib()

  abstract Str:DataDict map()

  override final Bool isEmpty() { map.isEmpty }

  override final DataDictX x() { MDataDictX(this) }

  override final Bool has(Str name) { map.get(name, null) != null }

  override final Bool missing(Str name) { map.get(name, null) == null }

  override final Obj? get(Str name, Obj? def := null) { map.get(name, def) }

  override final Obj? trap(Str n, Obj?[]? a := null) { MDataUtil.dictTrap(this, n) }

  override final Void each(|Obj,Str| f) { map.each(f) }

  override final Obj? eachWhile(|Obj,Str->Obj?| f) { map.eachWhile(f) }

  override final Str doc() { meta["doc"] as Str ?: "" }

  override final Str toStr() { qname }

}

