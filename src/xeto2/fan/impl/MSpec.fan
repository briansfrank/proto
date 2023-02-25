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
  new make(XetoEnv env, FileLoc loc, AtomicRef selfRef, AtomicRef typeRef, AtomicRef metaRef, MSlots slotsOwn, Obj? val)
  {
    this.envRef      = env
    this.loc         = loc
    this.selfRef     = selfRef
    this.typeRef     = typeRef
    this.metaRef     =  metaRef
    this.slotsOwnRef = slotsOwn
    this.val         = val
  }

  override XetoEnv env() { envRef }
  const XetoEnv envRef

  const AtomicRef selfRef

  const override FileLoc loc

  override MType type() { typeRef.val }
  internal const AtomicRef typeRef

  override MSlots slotsOwn() { slotsOwnRef }
  const MSlots slotsOwnRef

  override MSpec? slotOwn(Str name, Bool checked := true) { slotsOwnRef.get(name, checked) }

  const override Obj? val

  override Str toStr() { type.qname }

  DataDict meta() { metaRef.val }
  private const AtomicRef metaRef

  override DataSpec spec() { env.sys.spec }

  override Bool isEmpty() { meta.isEmpty }
  @Operator override Obj? get(Str name, Obj? def := null) { meta.get(name, def) }
  override Bool has(Str name) { meta.has(name) }
  override Bool missing(Str name) { meta.missing(name) }
  override Void each(|Obj val, Str name| f) { meta.each(f) }
  override Obj? eachWhile(|Obj val, Str name->Obj?| f) { meta.eachWhile(f) }
  override Obj? trap(Str name, Obj?[]? args := null) { meta.trap(name, args) }

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
      ofs := getInherited("ofs") as DataType[]
      if (ofs != null && ofs.any |x| { x.isa(that) }) return true
    }

    return false
  }

  // TODO: temp solution
  private Obj? getInherited(Str name)
  {
    val := get(name)
    if (val != null) return val
    for (MType? t := type; t != null; t = t.base)
    {
      val = t.get(name)
      if (val != null) return val
    }
    return null
  }

}