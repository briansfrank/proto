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
      inherit := acc[n]
      if (inherit != null) s = overrideSlot(inherit, s)
      acc[n] = s
    }

    return MSlots(acc)
  }

  ** Merge inherited slot 'a' with override slot 'b'
  static XetoSpec overrideSlot(XetoSpec a, XetoSpec b)
  {
    acc := Str:Obj[:]
    a.each |v, n| { acc[n] = v }
    b.each |v, n| { acc[n] = v }
    meta := a.env.dict(acc)

    return XetoSpec(MSpec(b.loc, b.parent, b.name, b.type, meta, b.slotsOwn, b.val ?: a.val))
  }

}

