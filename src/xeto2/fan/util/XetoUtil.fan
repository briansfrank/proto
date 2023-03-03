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

    supertype := spec.supertype as XetoType
    if (supertype == null) return own

    if (own.isEmpty) return supertype.m.meta

    acc := Str:Obj[:]
    supertype.m.meta.each |v, n|
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

