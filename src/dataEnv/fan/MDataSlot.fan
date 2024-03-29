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

    // TODO: derive new synthetic type if we have of
    if (astSlot.type.of != null) slotType = MDataType.parameterize(slotType, astSlot.type.of.map |x->DataType| { x.reified })

    // TODO
    this.constraints = astSlot.slots.map |x->DataType|
    {
      c := x.type.reified
      if (x.type.of != null) c = MDataType.parameterize(c, x.type.of.map |y->DataType| { y.reified })
      return c
    }
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

  static Dict mergeMeta(MDataEnv env, Dict inherit, Dict declared)
  {
    if (declared.isEmpty) return inherit
    if (inherit.isEmpty) return declared
    acc := Str:Obj[:]
    inherit.each |v, n| { acc[n] = v }
    declared.each |v, n| { acc[n] = v }
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
  const override Dict meta
  const override Str:DataType constraints
  override Str:Dict map() { env.emptyDictMap }

}