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
internal const class MLib : MSpec, DataLib
{
  new make(XetoEnv env, FileLoc loc, AtomicRef libRef, Str qname, Str name, AtomicRef baseRef, AtomicRef metaRef, Str:MSpec declared)
    : super(env, loc, libRef, baseRef, metaRef, declared, null)
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

  override MSpec? base() { super.base }

  @Operator override MSpec? get(Str name, Bool checked := true) { super.get(name, checked) }

  override Str toStr() { qname }

}