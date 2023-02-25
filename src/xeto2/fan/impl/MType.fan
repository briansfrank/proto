//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Feb 2023  Brian Frank  Creation
//

using concurrent
using util
using data2

**
** Implementation of DataLib
**
@Js
internal const class MType : MSpec, DataType
{
  new make(XetoEnv env, FileLoc loc, AtomicRef selfRef, AtomicRef libRef, Str qname, Str name, AtomicRef baseRef, AtomicRef metaRef, MSlots declared, Obj? val)
    : super(env, loc, selfRef, baseRef, metaRef, declared, val)
  {
    this.libRef = libRef
    this.qname  = qname
    this.name   = name
  }

  override XetoEnv env() { envRef }

  override MLib lib() { libRef.val }
  private const AtomicRef libRef

  const override Str qname

  const override Str name

  override DataSpec spec() { env.sys.type }

  override MType type() { this }

  override MType? base() { typeRef.val }  // use MSpec.typeRef as our base type

  override MSlots slotsOwn() { super.slotsOwn }

  override MSpec? slotOwn(Str name, Bool checked := true) { slotsOwnRef.get(name, checked) }

  override Str toStr() { qname }

  override Bool isaScalar() { inheritsFrom(env.sys.scalar) }
  override Bool isaMarker() { inheritsFrom(env.sys.marker) }
  override Bool isaSeq()    { inheritsFrom(env.sys.seq) }
  override Bool isaDict()   { inheritsFrom(env.sys.dict) }
  override Bool isaList()   { inheritsFrom(env.sys.list) }
  override Bool isaMaybe()  { inheritsFrom(env.sys.maybe) }
  override Bool isaAnd()    { inheritsFrom(env.sys.and) }
  override Bool isaOr()     { inheritsFrom(env.sys.or) }
  override Bool isaQuery()  { inheritsFrom(env.sys.query) }

  Bool inheritsFrom(DataType that)
  {
    if (this === that) return true
    base := this.base
    if (base == null) return false
    return base.inheritsFrom(that)
  }

}