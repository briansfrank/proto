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
internal const class MDataType : DataType
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
    type = make(lib, proto, base)
    types[name] = type

    stack.pop
    return type
  }


  new make(MDataLib lib, Proto p, MDataType? base)
  {
    this.lib      = lib
    this.name     = p.name
    this.qname    = lib.qname + "." + name
    this.loc      = p.loc
    this.base     = base
    this.meta    =  MProtoDict.fromMeta(lib.env, p)
    this.slots    = MDataSlot.fromPog(this, p)
    this.slotsMap = Str:MDataSlot[:].addList(slots) { it.name }
  }

  const override MDataLib lib
  const override FileLoc loc
  const override Str name
  const override Str qname
  const override DataDict meta
  override const DataType? base
  const override DataSlot[] slots
  const Str:DataSlot slotsMap

  override DataEnv env() { lib.env }

  override Str doc() { meta["doc"] as Str ?: "" }
  override Str toStr() { qname }

  override DataSlot? slot(Str name, Bool checked := true)
  {
    slot := slotsMap[name]
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