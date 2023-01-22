//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using util
using data
using pog

**
** DataSlot implementation
**
@Js
internal const class MDataSlot : MDataDef, DataSlot
{
  static MDataSlot[] fromPog(MDataType parent, Proto pog)
  {
    acc := MDataSlot[,]
    pog.each |kid|
    {
      if (kid.isField) acc.add(make(parent, kid))
    }
    return acc
  }

  new make(MDataType parent, Proto proto)
  {
    this.parent   = parent
    this.name     = proto.name
    this.loc      = proto.loc
    this.qname    = StrBuf(parent.qname.size + 1 + name.size).add(parent.qname).addChar('.').add(name).toStr
    this.meta     = MProtoDict.fromMeta(parent.env, proto)
    this.typeName = proto.isa.qname.toStr
  }

  override MDataEnv env() { parent.libRef.env }
  override MDataLib lib() { parent.libRef }
  override DataType type() { parent.libRef.env.sys.slot }

  const override MDataType parent
  const override FileLoc loc
  const override Str name
  const override Str qname
  override const DataDict meta
  override Str:DataDict map() { env.emptyMap }

  override MDataType slotType() { parent.env.type(typeName) }
  private const Str typeName
}