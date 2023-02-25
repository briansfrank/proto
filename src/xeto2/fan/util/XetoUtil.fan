//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Feb 2023  Brian Frank  Creation
//

using data2

**
** Utility functions
**
@Js
internal const class XetoUtil
{
  static DataDict inheritMeta(MSpec spec)
  {
    own := spec.own

    inherit := spec.type
    if (inherit === spec)
    {
      base := inherit.base
      if (base == null) return own
      inherit = base
    }

    if (own.isEmpty) return inherit.meta

    acc := Str:Obj[:]
    inherit.meta.each |v, n|
    {
      if (isMetaInherited(n)) acc[n] = v
    }
    own.each |v, n|
    {
      acc[n] = v
    }
    return spec.env.dict(acc)
  }

  static Bool isMetaInherited(Str name)
  {
    // we need to make this use reflection at some point
    if (name == "sealed") return false
    return true
  }
}

