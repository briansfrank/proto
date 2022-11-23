//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using util
using concurrent
using proto

**
** Proto implementation
**
@Js
internal const class MProto : Proto
{
  new make(FileLoc loc, Path path, AtomicRef baseRef, Str? val, Str:MProto children)
  {
    this.loc      = loc
    this.path     = path
    this.baseRef  = baseRef
    this.valRef   = val
    this.children = children
  }

  override const FileLoc loc

  override Str name() { path.name }

  override Str qname() { path.toStr }

  const Path path

  override Proto? type() { base.proto }

  MProtoBase base() { baseRef.val }
  private const AtomicRef baseRef

  override Bool hasVal() { valRef != null }

  override Str? val(Bool checked := true)
  {
    if (valRef != null) return valRef
    if (checked) throw ProtoMissingValErr(name)
    return null
  }
  private const Str? valRef

  override final Proto? trap(Str name, Obj?[]? args := null)
  {
    get(name, true)
  }

  override Bool has(Str name)
  {
    if (hasOwn(name)) return true
    return base.has(name)
  }

  override Bool hasOwn(Str name)
  {
    children.containsKey(name)
  }

  @Operator override Proto? get(Str name, Bool checked := true)
  {
    child := children.get(name, null) ?: base.get(name)
    if (child != null) return child
    if (checked) throw UnknownProtoErr(name)
    return null
  }

  override Proto? getOwn(Str name, Bool checked := true)
  {
    child := children.get(name, null)
    if (child != null) return child
    if (checked) throw UnknownProtoErr(name)
    return null
  }

  private const Str:MProto children

  override Void each(|Proto| f)
  {
    // expensive
    seen := Str:Str[:]
    eachSeen(seen, f)
  }

  Void eachSeen(Str:Str seen, |Proto| f)
  {
    children.each |kid|
    {
      if (seen[kid.name] != null) return
      seen[kid.name] = kid.name
      f(kid)
    }
    base.eachSeen(seen, f)
  }

  override Void eachOwn(|Proto| f)
  {
    children.each(f)
  }

  override Proto[] list()
  {
    acc := Proto[,]
    each |x| { acc.add(x) }
    return acc
  }

  override Proto[] listOwn()
  {
    children.vals
  }

  override Str toStr() { path.toStr }

  override Bool fits(Proto that)
  {
    this === that || base.fits(that)
  }

  override Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    indent := opts?.get("indent") as Str ?: ""
    out.print(indent).print(name)
    if (type != null) out.print(" : ").print(type)
    if (valRef != null) out.print(" ").print(valRef.toCode)
    if (children.size == 0) out.printLine
    else
    {
      kidOpts := (opts ?: Str:Obj?[:]).dup.set("indent", indent+"  ")
      out.printLine(" {")
      children.each |kid| { kid.dump(out, kidOpts) }
      out.print(indent).printLine("}")
    }
  }

  static const Str:MProto noChildren := [:]

}

