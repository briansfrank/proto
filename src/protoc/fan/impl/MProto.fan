//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent
using proto

**
** Proto implementation
**
internal const class MProto : Proto
{
  new make(Path path, AtomicRef typeRef, Str? val, Str:MProto children)
  {
    this.path     = path
    this.typeRef  = typeRef
    this.valRef   = val
    this.children = children
  }

  override Str name() { path.name }

  override const Path path

  override Proto? type() { typeRef.val }
  private const AtomicRef typeRef

  override Str? val(Bool checked := true)
  {
    if (valRef != null) return valRef
    if (checked) throw ProtoMissingValErr(name)
    return null
  }
  private const Str? valRef

  override final Obj? trap(Str name, Obj?[]? args := null)
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
    // TODO: need a better mechanism
    seen := Str:Str[:]
    doEach(seen, this,f)
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

  override Obj? eachWhile(|Proto->Obj?| f)
  {
    children.eachWhile(f)
    // TODO: lame
  }

  override Str toStr() { path.toStr }

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

}

