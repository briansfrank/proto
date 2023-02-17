//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data

**************************************************************************
** MAbstractDict
**************************************************************************

@Js
internal const abstract class MAbstractDict : Dict
{
  override Bool has(Str name) { get(name, null) != null }
  override Bool missing(Str name) { get(name, null) == null }
}

**************************************************************************
** MEmptyDict
**************************************************************************

@Js
internal const class MEmptyDict : MAbstractDict
{
  new make(DataType type) { this.type = type }
  const override DataType type
  override Bool has(Str name) { false }
  override Bool missing(Str name) { true }
  override Bool isEmpty() { true }
  override Obj? get(Str name, Obj? def := null) { def }
  override Obj? trap(Str n, Obj?[]? a := null) { throw UnknownSlotErr(n) }
  override Void each(|Obj, Str| f) {}
  override Obj? eachWhile(|Obj, Str->Obj?| f) { null }
  override Str toStr() { "{}" }
}

**************************************************************************
** MMapDict
**************************************************************************

@Js
internal const class MMapDict : MAbstractDict
{
  new make(DataType? type, Str:Obj? map) { this.typeRef = type; this.map = map }
  override DataType type() { typeRef ?: DataEnv.cur.type("sys.Dict") } // TODO
  const DataType? typeRef
  override Bool isEmpty() { map.isEmpty }
  override Obj? get(Str name, Obj? def := null) { map.get(name, def) }
  override Obj? trap(Str n, Obj?[]? a := null) { MDataUtil.dictTrap(this, n) }
  override Void each(|Obj,Str| f) { map.each(f) }
  override Obj? eachWhile(|Obj,Str->Obj?| f) { map.eachWhile(f) }
  override Str toStr() { MDataUtil.dictToStr(this) }
  const Str:Obj? map
}

