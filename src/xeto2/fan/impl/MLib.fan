//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Jan 2023  Brian Frank  Creation
//

using util
using data2

**
** Implementation of DataLib wrapped by XetoLib
**
@Js
internal const class MLib : MSpec
{
  new make(XetoEnv env, FileLoc loc, Str qname, XetoType libType, DataDict own, MSlots declared)
    : super(loc, null, "", libType, libType, own, declared)
  {
    this.env   = env
    this.qname = qname
  }

  const override XetoEnv env

  const override Str qname

  override DataSpec spec() { env.sys.lib }

  Version version()
  {
    // TODO
    return Version.fromStr(meta->version)
  }

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
  new make() : super() {}

  override Str qname() { ml.qname }

  override Version version() { ml.version }

  const MLib? ml
}

