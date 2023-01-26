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
  static const Str:MDataSlot emptyMap := [:]

  static Str:MDataSlot toMap(MDataSlot[] list)
  {
    if (list.isEmpty) return emptyMap
    return Str:MDataSlot[:].addList(list) { it.name }
  }

  static MDataSlot[] reify(MDataType parent, XetoObj astParent)
  {
    if (astParent.slots.isEmpty) return MDataSlot#.emptyList

    acc := MDataSlot[,]
    astParent.slots.each |astSlot|
    {
      acc.add(make(parent, astSlot))
    }
    return acc
  }

  new make(MDataType parent, XetoObj astSlot)
  {
    this.parent   = parent
    this.name     = astSlot.name
    this.loc      = astSlot.loc
    this.qname    = StrBuf(parent.qname.size + 1 + name.size).add(parent.qname).addChar('.').add(name).toStr
    this.meta     = parent.env.astMeta(astSlot.meta)
    this.slotType = astSlot.type.reified  // this will need to change to be lazy
  }

  override MDataEnv env() { parent.libRef.env }
  override MDataLib lib() { parent.libRef }
  override DataType type() { parent.libRef.env.sys.slot }

  const override MDataType parent
  const override FileLoc loc
  const override Str name
  const override Str qname
  const override MDataType slotType
  override const DataDict meta
  override Str:DataDict map() { env.emptyDictMap }

}