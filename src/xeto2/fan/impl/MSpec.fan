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
  new make(XetoEnv env, FileLoc loc, AtomicRef selfRef, AtomicRef typeRef, AtomicRef metaRef, Str:MSpec declared, Obj? val)
  {
    this.envRef   = env
    this.loc      = loc
    this.selfRef  = selfRef
    this.typeRef  = typeRef
    this.metaRef  = metaRef
    this.declared = declared
    this.val      = val
  }

  override XetoEnv env() { envRef }
  const XetoEnv envRef

  const AtomicRef selfRef

  const override FileLoc loc

  override MType? type() { typeRef.val }
  private const AtomicRef typeRef

  const Str:MSpec declared

  const override Obj? val

  override DataDict meta() { metaRef.val }
  private const AtomicRef metaRef

  override DataSpec[] list()  { declared.vals }

  @Operator override MSpec? get(Str name, Bool checked := true)
  {
    kid := declared[name]
    if (kid != null) return kid
    if (!checked) return null
    sep := this is MLib ? "::" : "."  // TODO
    throw UnknownSpecErr(toStr + sep + name)
  }

  override Str toStr() { type?.toStr ?: "???" }

  override Bool isa(DataSpec that)
  {
    if (this === that) return true
    type := this.type
    if (type == null) return false
    return type.isa(that)
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