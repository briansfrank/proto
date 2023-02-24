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

  override MSlots declared() { super.declared }

  override Str toStr() { qname }

  override Bool isa(DataType that)
  {
    if (this === that) return true
    base := this.base
    if (base == null) return false
    return base.isa(that)
  }

  override Bool isaScalar() { isa(env.sys.scalar) }
  override Bool isaMarker() { isa(env.sys.marker) }
  override Bool isaSeq()    { isa(env.sys.seq) }
  override Bool isaDict()   { isa(env.sys.dict) }
  override Bool isaList()   { isa(env.sys.list) }
  override Bool isaMaybe()  { isa(env.sys.maybe) }
  override Bool isaAnd()    { isa(env.sys.and) }
  override Bool isaOr()     { isa(env.sys.or) }
  override Bool isaQuery()  { isa(env.sys.query) }

}