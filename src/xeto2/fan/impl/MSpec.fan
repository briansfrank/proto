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
  new make(FileLoc loc, AtomicRef libRef, Str qname, Str name, AtomicRef baseRef, DataDict meta, Str:MSpec declared, Obj? val)
  {
    this.loc      = loc
    this.libRef   = libRef
    this.qname    = qname
    this.name     = name
    this.baseRef  = baseRef
    this.meta     = meta
    this.declared = declared
    this.val      = val
  }

  override XetoEnv env() { lib.envRef }

  override MLib lib() { libRef.val }
  private const AtomicRef libRef

  const override FileLoc loc

  const override Str qname

  const override Str name

  override MSpec? base() { baseRef.val }
  private const AtomicRef baseRef

  const Str:MSpec declared

  const override Obj? val

  override const DataDict meta

  override DataSpec[] list()  { declared.vals }

  @Operator override DataSpec? get(Str name, Bool checked := true)
  {
    kid := declared[name]
    if (kid != null) return kid
    if (!checked) return null
    sep := this is MLib ? "::" : "."
    throw UnknownSpecErr("$qname$sep$name")
  }

  override Str toStr() { qname }

  override Bool isa(DataSpec that)
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