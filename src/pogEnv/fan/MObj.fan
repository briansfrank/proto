//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Dec 2022  Brian Frank  Creation
//

using concurrent
using pog
using util

**
** Implementation for root object type
**
@Js
internal const class MObj : Proto
{
  new make(MProtoInit init)
  {
    this.loc      = init.loc
    this.qname    = init.qname
    this.children = init.children
  }

  override ProtoSpi spi() { throw Err("TODO") }

  override Str name() { qname.name }

  override const QName qname

  override Bool isMeta() { false }

  override Proto? isa() { null }

  override Int tx() { 0 }

  override final Str toStr() { qname.toStr }

  override Bool hasVal() { false }

  override Obj? val(Bool checked := true)
  {
    valOwn(checked)
  }

  override Obj? valOwn(Bool checked := true)
  {
    if (checked) throw ProtoMissingValErr(qname.toStr)
    return null
  }

  override Bool has(Str name)
  {
    hasOwn(name)
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
    getOwn(name, checked)
  }

  override Proto? getOwn(Str name, Bool checked := true)
  {
    child := children.get(name, null)
    if (child != null) return child
    if (checked) throw UnknownProtoErr(name + " WTF checked=$checked")
    return null
  }

  internal const Str:Proto children

  override Void each(|Proto| f)
  {
    eachOwn(f)
  }

  override Void eachSeen(Str:Str seen, |Proto| f)
  {
    children.each |kid|
    {
      if (seen[kid.name] != null) return
      seen[kid.name] = kid.name
      f(kid)
    }
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
    this === that
  }

  override const FileLoc loc

  override Void print(OutStream out := Env.cur.out, [Str:Obj]? opts := null)
  {
    PogUtil.print(this, out, opts)
  }
}

