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
  new make(XetoEnv env, FileLoc loc, AtomicRef selfRef, AtomicRef typeRef, AtomicRef metaRef, MSlots declared, Obj? val)
  {
    this.envRef      = env
    this.loc         = loc
    this.selfRef     = selfRef
    this.typeRef     = typeRef
    this.metaRef     =  metaRef
    this.declaredRef = declared
    this.val         = val
  }

  override XetoEnv env() { envRef }
  const XetoEnv envRef

  const AtomicRef selfRef

  const override FileLoc loc

  override MType type() { typeRef.val }
  internal const AtomicRef typeRef

  override MSlots declared() { declaredRef }
  const MSlots declaredRef

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
}