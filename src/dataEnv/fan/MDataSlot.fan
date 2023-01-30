//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data
using xeto

**
** DataSlot implementation
**
@Js
internal const class MDataSlot : MDataDef, DataSlot
{
  new make(MDataType parent, XetoObj astSlot)
  {
    this.parent   = parent
    this.name     = astSlot.name
    this.loc      = astSlot.loc
    this.qname    = StrBuf(parent.qname.size + 1 + name.size).add(parent.qname).addChar('.').add(name).toStr
    this.meta     = parent.env.astMeta(astSlot.meta)
    this.slotType = astSlot.type.reified

    // TODO
    this.constraints = astSlot.slots.map |x->DataType| { x.type.reified }
  }

  new makeOverride(MDataSlot inherit, MDataSlot declared)
  {
    this.parent      = declared.parent
    this.name        = declared.name
    this.loc         = declared.loc
    this.qname       = declared.qname
    this.meta        = mergeMeta(parent.env, inherit.meta, declared.meta)
    this.slotType    = declared.slotType
    this.constraints = mergeConstraints(inherit.constraints, declared.constraints)
  }

  static DataDict mergeMeta(MDataEnv env, DataDict inherit, DataDict declared)
  {
    if (declared.isEmpty) return inherit
    if (inherit.isEmpty) return declared
    acc := Str:Obj[:]
    inherit.x.each |v, n| { acc[n] = v }
    declared.x.each |v, n| { acc[n] = v }
    return env.dict(acc)
  }

  static Str:MDataType mergeConstraints(Str:MDataType inherit, Str:MDataType declared)
  {
    if (declared.isEmpty) return inherit
    if (inherit.isEmpty) return declared

    acc := inherit.dup

    // TODO: this belongs in a utility
    autoIndex := 0
    acc.each |x, n|
    {
      if (!n.startsWith("_")) return
      int := n[1..-1].toInt(10, false)
      if (int != null) autoIndex = autoIndex.max(int)
    }

    declared.each |x, n|
    {
      if (n.startsWith("_")) n = "_" + (++autoIndex)
      acc[n] = x
    }

    return acc
  }

  override MDataEnv env() { parent.libRef.env }
  override MDataLib lib() { parent.libRef }
  override DataType type() { parent.libRef.env.sys.slot }

  const override MDataType parent
  const override FileLoc loc
  const override Str name
  const override Str qname
  const override MDataType slotType
  const override DataDict meta
  const override Str:DataType constraints
  override Str:DataDict map() { env.emptyDictMap }

}