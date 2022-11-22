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
  new make(FileLoc loc, Path path, AtomicRef typeRef, Str? val, Str:MProto children)
  {
    this.loc      = loc
    this.path     = path
    this.typeRef  = typeRef
    this.valRef   = val
    this.children = children
  }

  override const FileLoc loc

  override Str name() { path.name }

  override Str qname() { path.toStr }

  const Path path

  override Proto? type() { typeRef.val }
  private const AtomicRef typeRef

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
    if (type == null) return false
    return type.has(name)
  }

  override Bool hasOwn(Str name)
  {
    children.containsKey(name)
  }

  @Operator override Proto? get(Str name, Bool checked := true)
  {
    child := children.get(name, null)
    if (child != null) return child
    child = type?.get(name, false)
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
    doEach(seen, this, f)
  }

  private static Void doEach(Str:Str seen, MProto? p, |Proto| f)
  {
    if (p == null) return
    p.children.each |kid|
    {
      if (seen[kid.name] != null) return
      seen[kid.name] = kid.name
      f(kid)
    }
    doEach(seen, p.type, f)
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

  override Bool fits(Proto base)
  {
    // TODO: need to handle or/and
    if (this === base) return true
    if (type == null) return false
    return type.fits(base)
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

