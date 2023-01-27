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
** DataType implementation
**
@Js
internal const class MDataType : MDataDef, DataType
{
  static MDataType[] reify(MDataLib lib, XetoObj astLib)
  {
    acc := MDataType[,]
    acc.capacity = astLib.slots.size
    stack := Str[,]
    astLib.slots.each |astType| { acc.add(doReify(lib, astLib, astType, stack)) }
    return acc
  }

  private static MDataType doReify(MDataLib lib, XetoObj astLib, XetoObj astType, Str[] stack)
  {
    // skip if already reified
    if (astType.reified != null) return astType.reified

    // push name onto stack to catch cyclic inheritance
    name := astType.name
    if (stack.contains(name)) throw Err("Cyclic type inheritance: $stack")
    stack.push(name)

    // resolve base which is either inside AST or from outside depend
    DataType? base := null
    if (astType.type != null)
    {
      if (astType.type.inside != null)
        base = doReify(lib, astLib, astType.type.inside, stack)
      else
        base = astType.type.outside
    }

    astType.reified = init(lib, astType, base)

    stack.pop
    return astType.reified
  }

  private static MDataType init(MDataLib lib, XetoObj ast, MDataType? base)
  {
    if (lib.qname != "sys")
    {
      if (base === lib.env.sys.func) return MDataFunc(lib, ast, base)
    }
    return make(lib, ast, base)
  }

  new make(MDataLib lib, XetoObj ast, MDataType? base)
  {
    this.libRef = lib
    this.name   = ast.name
    this.qname  = lib.qname + "." + name
    this.loc    = ast.loc
    this.base   = base
    this.meta   = lib.env.astMeta(ast.meta)
    this.slots  = MDataSlot.reify(this, ast)
    this.map    = MDataSlot.toMap(this.slots)
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

  override Bool isa(DataType that)
  {
    if (this === that) return true
    if (base == null) return false
    return base.isa(that)
  }

  override Bool isaScalar() { isa(env.sys.scalar) }
  override Bool isaMarker() { isa(env.sys.marker) }
  override Bool isaSeq()    { isa(env.sys.seq) }
  override Bool isaDict()   { isa(env.sys.dict) }
  override Bool isaList()   { isa(env.sys.list) }
  override Bool isaMaybe()  { isa(env.sys.maybe) }
  override Bool isaAnd()    { isa(env.sys.and) }
  override Bool isaOr()     { isa(env.sys.or) }

}