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
  ** Inherit spec meta data
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
    if (name == "abstract") return false
    if (name == "sealed") return false
    return true
  }

  ** Inherit spec slots
  static MSlots inheritSlots(MSpec spec)
  {
    own := spec.slotsOwn
    supertype := spec.supertype

    if (supertype == null) return own
    if (own.isEmpty) return supertype.slots

    // add supertype slots
    acc := Str:XetoSpec[:]
    acc.ordered = true
    supertype.slots.each |s, n|
    {
      acc[n] = s
    }

    // add in my own slots
    own.each |s, n|
    {
      dup := acc[n]
      if (dup != null) throw Err("TODO")
      acc[n] = s
    }

    return MSlots(acc)
  }
}

