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
  new make(XetoEnv env, FileLoc loc, AtomicRef selfRef, AtomicRef libRef, Str qname, Str name, AtomicRef typeRef, AtomicRef metaRef, MSlots declared, Obj? val)
    : super(env, loc, selfRef, typeRef, metaRef, declared, val)
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

  override MType? type() { super.type }

  override MSlots declared() { super.declared }

  override Str toStr() { qname }

}