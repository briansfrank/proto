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
  new make(XetoEnv env, FileLoc loc, AtomicRef libRef, Str qname, Str name, AtomicRef baseRef, DataDict meta, Str:MSpec declared)
    : super(loc, libRef, qname, name, baseRef, meta, declared, null)
  {
    this.envRef = env
  }

  const XetoEnv envRef

  override Version version() { throw Err("TODO") }

  override MSpec? base() { super.base }

  override MLib lib() { this }
}