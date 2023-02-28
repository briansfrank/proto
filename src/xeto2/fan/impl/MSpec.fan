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
** Implementation of DataLib
**
@Js
internal const class MSpec : DataSpec
{
  new make(XetoEnv env, FileLoc loc, AtomicRef selfRef, AtomicRef typeRef, AtomicRef ownRef, MSlots slotsOwn, Obj? val)
  {
    this.envRef      = env
    this.loc         = loc
    this.selfRef     = selfRef
    this.typeRef     = typeRef
    this.ownRef      = ownRef
    this.slotsOwnRef = slotsOwn
    this.val         = val
  }

  override XetoEnv env() { envRef }
  const XetoEnv envRef

  const AtomicRef selfRef

  const override FileLoc loc

  override MType type() { typeRef.val }
  internal const AtomicRef typeRef

  override MSlots slots() { slotsOwn }  // TODO

  override MSlots slotsOwn() { slotsOwnRef }
  const MSlots slotsOwnRef

  override MSpec? slot(Str name, Bool checked := true) { slots.get(name, checked) }

  override MSpec? slotOwn(Str name, Bool checked := true) { slotsOwnRef.get(name, checked) }

  const override Obj? val

  override Str toStr() { type.qname }

  override DataDict own() { ownRef.val }
  private const AtomicRef ownRef

  override DataSpec spec() { env.sys.spec }

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

  override Bool isEmpty() { meta.isEmpty }
  @Operator override Obj? get(Str name, Obj? def := null) { meta.get(name, def) }
  override Bool has(Str name) { meta.has(name) }
  override Bool missing(Str name) { meta.missing(name) }
  override Void each(|Obj val, Str name| f) { meta.each(f) }
  override Obj? eachWhile(|Obj val, Str name->Obj?| f) { meta.eachWhile(f) }
  override Obj? trap(Str name, Obj?[]? args := null) { meta.trap(name, args) }

//////////////////////////////////////////////////////////////////////////
// Is-A
//////////////////////////////////////////////////////////////////////////

  override Bool isa(DataSpec that)
  {
    thisType := this.type
    thatType := that.type

    // check type tree
    // TODO: need to check of covariance
    if (thisType.inheritsFrom(thatType))
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
      of := this["of"] as DataType
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