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
** Implementation of DataLib wrapped by XetoLib
**
@Js
internal const class MLib : MSpec, DataLib
{
  new make(XetoEnv env, FileLoc loc, AtomicRef libRef, Str qname, Str name, AtomicRef typeRef, AtomicRef ownRef, MSlots declared)
    : super(env, loc, libRef, typeRef, ownRef, declared, null)
  {
    this.qname = qname
  }

  override XetoEnv env() { envRef }

  override const Str qname

  override Version version()
  {
    // TODO
    return Version.fromStr(meta->version)
  }

  override MType type() { envRef.sys.lib }

  override MSlots slots() { super.slots }

  override MSlots slotsOwn() { super.slotsOwn }

  override MSpec? slot(Str name, Bool checked := true) { slots.get(name, checked) }

  override MSpec? slotOwn(Str name, Bool checked := true) { slotsOwnRef.get(name, checked) }

  override Str toStr() { qname }

}

**************************************************************************
** XetoLib
**************************************************************************

**
** XetoLib is the referential proxy for MLib
**
@Js
internal const class XetoLib : XetoSpec, DataLib
{
  override Str qname() { ml.qname }

  override Version version() { ml.version }

  const MLib? ml
}

