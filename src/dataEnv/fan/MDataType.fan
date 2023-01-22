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
** DataType implementation
**
@Js
internal const class MDataType : MDataDef, DataType
{
  static MDataType[] fromPog(MDataLib lib, Proto pog)
  {
    // build map of proto types
    protos := Str:Proto[:] { ordered = true }
    pog.eachOwn |kid| { if (kid.isType) protos[kid.name] = kid }

    // recursively map to MDataTypes
    types := Str:MDataType[:]
    stack := Str[,]
    protos.each |p, n| { doFromPog(lib, protos, types, n, stack) }

    // flatten back to ordered list
    acc := DataType[,]
    acc.capacity = types.size
    protos.each |p, n| { acc.add(types.getChecked(n)) }
    return acc
  }

  private static MDataType doFromPog(MDataLib lib, Str:Proto protos, Str:MDataType types, Str name, Str[] stack)
  {
    // skip if already mapped
    type := types[name]
    if (type != null) return type

    // push name onto stack to catch cyclic inheritance
    if (stack.contains(name)) throw Err("Cyclic inheritance: $stack")
    stack.push(name)

    // get proto and resolve its base
    // TODO just sys right now
    proto := protos[name]
    DataType? base := null
    if (proto.isa != null)
    {
      if (proto.isa.qname.lib.toStr == lib.qname)
        base = doFromPog(lib, protos, types, proto.isa.name, stack)
      else
        base = lib.env.type(proto.isa.qname.toStr)
    }

    type = init(lib, proto, base)
    types[name] = type

    stack.pop
    return type
  }

  private static MDataType init(MDataLib lib, Proto proto, MDataType? base)
  {
    if (lib.qname != "sys")
    {
      if (base === lib.env.sys.func) return MDataFunc(lib, proto, base)
    }
    return make(lib, proto, base)
  }

  new make(MDataLib lib, Proto p, MDataType? base)
  {
    this.libRef = lib
    this.name   = p.name
    this.qname  = lib.qname + "." + name
    this.loc    = p.loc
    this.base   = base
    this.meta   =  MProtoDict.fromMeta(lib.env, p)
    this.slots  = MDataSlot.fromPog(this, p)
    this.map    = Str:MDataSlot[:].addList(slots) { it.name }
  }

  override MDataEnv env() { libRef.env }
  override MDataLib lib() { libRef }
  override DataType type() { libRef.env.sys.type }

  const MDataLib libRef
  const override FileLoc loc
  const override Str name
  const override Str qname
  const override DataDict meta
  const override DataType? base
  const override DataSlot[] slots
  const override Str:DataSlot map

  override DataSlot? slot(Str name, Bool checked := true)
  {
    slot := map[name]
    if (slot != null) return slot
    if (checked) throw UnknownSlotErr("${qname}.${name}")
    return null
  }

  override Bool fits(DataType that)
  {
    if (this === that) return true
    if (base == null) return false
    return base.fits(that)
  }

}