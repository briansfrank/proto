//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//

using concurrent
using pog
using util

**
** Basic implementation for proto
**
@Js
internal const class MProto : Proto
{
  new make(MProtoInit init)
  {
    this.loc      = init.loc
    this.qname    = init.qname
    this.isaRef   = init.isa
    this.valRef   = init.val
    this.children = init.children
  }

  override Str name() { qname.name }

  override const QName qname

  override Bool isMeta() { qname.isMeta }

  override Proto? isa() { isaRef.val }
  private const AtomicRef isaRef

  override Int tx() { 0 }

  override final Str toStr() { qname.toStr }

  override Bool hasVal() { val(false) != null }

  override Obj? val(Bool checked := true)
  {
    if (valRef != null) return valRef
    return isa.val(checked)
  }

  override Obj? valOwn(Bool checked := true)
  {
    if (valRef != null) return valRef
    if (checked) throw ProtoMissingValErr(qname.toStr)
    return null
  }
  private const Obj? valRef

  override Bool has(Str name)
  {
    if (hasOwn(name)) return true
    return isa.has(name)
  }

  override Bool hasOwn(Str name)
  {
    children.containsKey(name)
  }

  override final Proto? trap(Str name, Obj?[]? args := null)
  {
    get(name, true)
  }

  @Operator override Proto? get(Str name, Bool checked := true)
  {
    child := children.get(name, null) ?: isa.get(name, false)
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

  internal const Str:Proto children

  override Void each(|Proto| f)
  {
    // expensive
    seen := Str:Str[:]
    eachSeen(seen, f)
  }

  override Void eachSeen(Str:Str seen, |Proto| f)
  {
    children.each |kid|
    {
      if (seen[kid.name] != null) return
      seen[kid.name] = kid.name
      f(kid)
    }
    isa.eachSeen(seen, f)
  }

  override Void eachOwn(|Proto| f)
  {
    children.each(f)
  }

  override Obj? eachOwnWhile(|Proto->Obj?| f)
  {
    children.eachWhile(f)
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

  override Bool fits(Proto that)
  {
    this === that || isa.fits(that)
  }

  override const FileLoc loc

  override Void print(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    PogUtil.print(this, out, opts)
  }

}
