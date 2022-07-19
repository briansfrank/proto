//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto

**
** Proto implementation
**
internal const class MProto : Proto
{
  new make(Path path, MProto? type, Str? val, Str:MProto children)
  {
    this.path     = path
    this.type     = type
    this.valRef   = val
    this.children = children
  }

  override Str name() { path.name }

  override const Path path

  override const Proto? type

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

  @Operator override Proto? get(Str name, Bool checked := true)
  {
    child := children.get(name, null)
    if (child != null) return child
    child = type?.get(name, false)
    if (child != null) return child
    if (checked) throw UnknownProtoErr(name)
    return null
  }

  override Proto? declared(Str name) { children.get(name, null) }

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

  override Obj? eachWhile(|Proto->Obj?| f)
  {
    children.eachWhile(f)
    // TODO: lame
  }

  override Str toStr() { path.toStr }

  override Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    indent := opts?.get("indent") as Str ?: ""
    out.print(indent).print(name).print(" : ")
    if (type != null) out.print(type)
    if (valRef != null) out.print(" = ").print(valRef.toCode)
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

