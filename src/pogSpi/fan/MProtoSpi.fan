//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using util
using concurrent
using pog

**
** Proto service provider implementation
**
@Js
const class MProtoSpi : ProtoSpi
{
  new make(FileLoc loc, QName qname, Int tx, AtomicRef baseRef, Obj? val, Str:Proto children)
  {
    this.loc      = loc
    this.qname    = qname
    this.baseRef  = baseRef
    this.valRef   = val
    this.children = children
    this.tx       = tx
  }

  override const FileLoc loc

  override Str name() { qname.name }

  override const QName qname

  override const Int tx

  override Proto? type() { base.proto }

  MProtoBase base() { baseRef.val }
  internal const AtomicRef baseRef


  override Bool hasVal() { valRef != null }

  override Obj? val(Bool checked)
  {
    if (valRef != null) return valRef
    if (checked) throw ProtoMissingValErr(name)
    return null
  }
  private const Obj? valRef

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
    base.eachSeen(seen, f)
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

  override Str toStr() { qname.toStr }

  override Bool fits(Proto that)
  {
    this === that.spi || base.fits(that)
  }

  override Void dump(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    indent := opts?.get("indent") as Str ?: ""
    if (qname.isRoot)
    {
      out.print(type)
    }
    else
    {
      out.print(indent).print(name)
      if (type != null) out.print(": ").print(type)
    }
    if (valRef != null) out.print(" ").print(valRef.toStr.toCode)
    if (children.size == 0) out.printLine
    else
    {
      kidOpts := (opts ?: Str:Obj?[:]).dup.set("indent", indent+"  ")
      out.printLine(" {")
      children.each |kid| { kid.dump(out, kidOpts) }
      out.print(indent).printLine("}")
    }
  }

  static const Str:Proto noChildren := [:] { ordered = true }

}

