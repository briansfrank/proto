//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Jan 2023  Brian Frank  Creation
//

using concurrent
using util
using data2


**
** Implementation of DataSpec wrapped by XetoSpec
**
@Js
internal const class MSpec
{
  new make(FileLoc loc, XetoSpec? parent, XetoType type, DataDict own, MSlots slotsOwn, Obj? val)
  {
    this.loc      = loc
    this.parent   = parent
    this.type     = type
    this.own      = own
    this.slotsOwn = slotsOwn
    this.val      = val
  }

  virtual XetoEnv env() { parent.env }

  const FileLoc loc

  const XetoSpec? parent

  const XetoType type

  virtual DataType? supertype() { type }

  once MSlots slots() { XetoUtil.inheritSlots(this) }

  const MSlots slotsOwn

  XetoSpec? slot(Str name, Bool checked := true) { slots.get(name, checked) }

  XetoSpec? slotOwn(Str name, Bool checked := true) { slotsOwn.get(name, checked) }

  const Obj? val

  override Str toStr() { type.qname }

  const DataDict own

  virtual DataSpec spec() { env.sys.spec }

//////////////////////////////////////////////////////////////////////////
// Effective Meta
//////////////////////////////////////////////////////////////////////////

  DataDict meta()
  {
    meta := metaRef.val
    if (meta != null) return meta
    metaRef.compareAndSet(null, XetoUtil.inheritMeta(this))
    return metaRef.val
  }
  private const AtomicRef metaRef := AtomicRef()

  Bool isEmpty() { meta.isEmpty }
  Obj? get(Str name, Obj? def := null) { meta.get(name, def) }
  Bool has(Str name) { meta.has(name) }
  Bool missing(Str name) { meta.missing(name) }
  Void each(|Obj val, Str name| f) { meta.each(f) }
  Obj? eachWhile(|Obj val, Str name->Obj?| f) { meta.eachWhile(f) }
  override Obj? trap(Str name, Obj?[]? args := null) { meta.trap(name, args) }

//////////////////////////////////////////////////////////////////////////
// Is-A
//////////////////////////////////////////////////////////////////////////

  Bool isa(XetoSpec that)
  {
    thisType := this.type
    thatType := that.type

    // check type tree
    // TODO: need to check of covariance
    if (thisType.mt.isaX(thatType))
      return true

    /*
    if (thatType.isaMaybe)
    {
      of := that["of"] as DataType
      if (of != null) return that.isa(of)
    }
    */

    if (thisType.isaMaybe)
    {
      of := get("of") as DataType
      if (of != null) return of.isa(that)
    }

    if (thisType.isaAnd)
    {
      ofs := get("ofs", null) as DataType[]
      if (ofs != null && ofs.any |x| { x.isa(that) }) return true
    }

    return false
  }

}

**************************************************************************
** XetoSpec
**************************************************************************

**
** XetoSpec is the referential proxy for MSpec
**
@Js
internal const class XetoSpec : DataSpec
{
  new make() {}

  new makem(MSpec m) { this.m = m }

  override DataEnv env() { m.env }

  override DataSpec? parent() { m.parent }

  override DataType type() { m.type }

  override DataType? supertype() { m.supertype }

  override DataDict own() { m.own }

  override DataSlots slotsOwn() { m.slotsOwn }

  override DataSlots slots() { m.slots }

  override DataSpec? slot(Str n, Bool c := true) { m.slot(n, c) }

  override DataSpec? slotOwn(Str n, Bool c := true) { m.slotOwn(n, c) }

  override Obj? val() { m.val }

  override Bool isa(DataSpec x) { m.isa(x) }

  override FileLoc loc() { m.loc }

  override DataSpec spec() { m.spec }

  override Bool isEmpty() { m.isEmpty }

  @Operator override Obj? get(Str n, Obj? d := null) { m.get(n, d) }

  override Bool has(Str n) { m.has(n) }

  override Bool missing(Str n) { m.missing(n) }

  override Void each(|Obj val, Str name| f) { m.each(f) }

  override Obj? eachWhile(|Obj,Str->Obj?| f) { m.eachWhile(f) }

  override Obj? trap(Str n, Obj?[]? a := null) { m.trap(n, a) }

  override Str toStr() { m?.toStr ?: super.toStr }

  const MSpec? m
}