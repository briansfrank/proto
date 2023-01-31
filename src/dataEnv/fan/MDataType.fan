//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 2023  Brian Frank  Creation
//

using concurrent
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
    // first reify the types
    astTypes := astLib.slots.vals
    acc := MDataType[,]
    acc.capacity = astTypes.size
    stack := Str[,]
    astTypes.each |astType| { acc.add(doReify(lib, astLib, astType, stack)) }

    // now that all the types are reified we can finalize the slots
    acc.each |type, i| { type.reifySlots(astTypes[i]) }

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
    of := MDataType#.emptyList
    if (astType.type != null)
    {
      // resolve type as base
      base = doReifyType(lib, astLib, astType.type, stack)

      // resolve of
      if (astType.type.of != null)
        of = astType.type.of.map |astOf->MDataType| { doReifyType(lib, astLib, astOf, stack) }
    }

    astType.reified = init(lib, astType, base, of)

    stack.pop
    return astType.reified
  }

  private static MDataType doReifyType(MDataLib lib,  XetoObj astLib, XetoType ast, Str[] stack)
  {
    if (ast.inside != null)
      return doReify(lib, astLib, ast.inside, stack)
    else
      return ast.outside
  }

  private static MDataType init(MDataLib lib, XetoObj ast, MDataType? base, MDataType[] of)
  {
    if (lib.qname != "sys")
    {
      if (base === lib.env.sys.func) return MDataFunc(lib, ast, base)
    }
    return make(lib, ast, base, of)
  }

  new make(MDataLib lib, XetoObj ast, MDataType? base, MDataType[] of)
  {
    this.libRef   = lib
    this.name     = ast.name
    this.qname    = lib.qname + "." + name
    this.loc      = ast.loc
    this.baseRef  = base
    this.meta     = lib.env.astMeta(ast.meta)
    this.ofs      = of   // TODO: this eventually needs to go into meta
  }

  internal Void reifySlots(XetoObj ast)
  {
    declaredSlotsRef.val = MDataTypeSlots.reify(this, ast)
  }

  override MDataEnv env() { libRef.env }
  override MDataLib lib() { libRef }
  override DataType type() { libRef.env.sys.type }

  const MDataLib libRef
  const override FileLoc loc
  const override Str name
  const override Str qname
  const override DataDict meta
  override DataType? base() { baseRef }
  const MDataType? baseRef
  private const AtomicRef declaredSlotsRef := AtomicRef()

  // TODO: just temp solution
  override DataType of() { ofs.first ?: throw Err("No of meta") }
  const override DataType[] ofs

  override Str:DataSlot map() { effectiveSlots.map }

  override DataSlot[] slots() { effectiveSlots.list }

  override DataSlot? slot(Str name, Bool checked := true)
  {
    slot := effectiveSlots.map[name]
    if (slot != null) return slot
    if (checked) throw UnknownSlotErr("${qname}.${name}")
    return null
  }

  MDataTypeSlots effectiveSlots()
  {
    x := effectiveSlotsRef.val as MDataTypeSlots
    if (x == null) effectiveSlotsRef.val = x = MDataTypeSlots.inherit(this, declaredSlotsRef.val)
    return x
  }
  private const AtomicRef effectiveSlotsRef := AtomicRef()

  override Bool isa(DataType that) { doIsa(that, ofs) }

  private Bool doIsa(DataType that, DataType[] ofs)
  {
    if (this === that) return true
    if (base == null) return false

    if (this === env.sys.maybe)
    {
      of := ofs.first
      if (of != null && of.isa(that)) return true
    }
    else if (this === env.sys.and)
    {
      if (ofs.any |x| { x.isa(that) }) return true
    }

    if (ofs.isEmpty) ofs = this.ofs

    return baseRef.doIsa(that, ofs)
  }

  override Bool isaScalar() { isa(env.sys.scalar) }
  override Bool isaMarker() { isa(env.sys.marker) }
  override Bool isaSeq()    { isa(env.sys.seq) }
  override Bool isaDict()   { isa(env.sys.dict) }
  override Bool isaList()   { isa(env.sys.list) }
  override Bool isaMaybe()  { isa(env.sys.maybe) }
  override Bool isaAnd()    { isa(env.sys.and) }
  override Bool isaOr()     { isa(env.sys.or) }
  override Bool isaQuery()  { isa(env.sys.query) }

}

**************************************************************************
** MDataTypeSlotMap
**************************************************************************

@Js
internal const class MDataTypeSlots
{
  const static MDataTypeSlots empty := MDataTypeSlots(MDataSlot[,], Str:MDataSlot[:])

  ** Reify the declared slots
  static MDataTypeSlots reify(MDataType parent, XetoObj astParent)
  {
    astSlots := astParent.slots
    if (astSlots.isEmpty) return empty

    list := MDataSlot[,] { it.capacity = astSlots.size }
    map := Str:MDataSlot[:]
    astSlots.each |astSlot|
    {
      slot := MDataSlot(parent, astSlot)
      list.add(slot)
      map.add(slot.name, slot)
    }
    return make(list, map)
  }

  ** Lazily build inherited slot map
  static MDataTypeSlots inherit(MDataType parent, MDataTypeSlots declared)
  {
    // no base (Obj), then return declared
    if (parent.base == null) return declared
    inherited := ((MDataType)parent.base).effectiveSlots

    // handle specials
    if (parent.isaAnd) return inheritAnd(inherited, parent.ofs, declared)
    if (parent.isaOr) throw Err("Or types not supported yet $parent.qname")

    // if inherited is empty, return declared
    if (inherited.isEmpty) return declared

    // TODO: when to report collision errors
    list := inherited.list.dup
    map := inherited.map.dup
    declared.list.each |slot|
    {
      name := slot.name
      if (map[name] == null)
      {
        list.add(slot)
        map.add(name, slot)
      }
      else
      {
        i := list.findIndex |x| { x.name == name } // TODO: quick replace in same order
        slot = MDataSlot.makeOverride(list[i], slot)
        list[i] = slot
        map[name] = slot
      }
    }
    return make(list, map)
  }

  ** Lazily build AND slot map
  static MDataTypeSlots inheritAnd(MDataTypeSlots base, MDataType[] ofs, MDataTypeSlots declared)
  {
    // TODO: no error checking at all!
    map := Str:MDataSlot[:]
    map.ordered = true

    // first add inheritance
    base.list.each |s| { map.add(s.name, s) }

    // then merge in each of the of types
    ofs.each |of|
    {
      ofSlots := ((MDataType)of).effectiveSlots
      ofSlots.list.each |s| { if (map[s.name] == null) map[s.name] = s }
    }

    // then add in declared
    declared.list.each |s|
    {
      if (map[s.name] == null) map[s.name] = s
    }

    return make(map.vals, map)
  }

  private new make(MDataSlot[] list, Str:MDataSlot map)
  {
    this.list = list
    this.map  = map
  }

  const MDataSlot[] list
  const Str:MDataSlot map
  Int size() { list.size }
  Bool isEmpty() { list.isEmpty }
}

