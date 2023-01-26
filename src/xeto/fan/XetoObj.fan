//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Jan 2023  Brian Frank  Creation
//

using util

**
** Xeto parsed object
**
@Js
class XetoObj
{
  new make(FileLoc loc)
  {
    this.loc = loc
  }

  const FileLoc loc
  Str? doc
  Str? name
  XetoType? type
  Str:XetoObj meta := emptyMap
  Str:XetoObj slots := emptyMap
  Str? val

  Str? add(XetoObj child, Bool isMeta)
  {
    if (child.name == null)
      child.name = autoName(isMeta)

    if (isMeta)
      return addMeta(child)
    else
      return addSlot(child)
  }

  Str? addMeta(XetoObj child)
  {
    if (meta.isEmpty) meta = newMap
    if (meta[child.name] != null) return "Duplicate meta '$name'"
    meta[child.name] = child
    return null
  }

  Str? addSlot(XetoObj child)
  {
    if (slots.isEmpty) slots = newMap
    if (slots[child.name] != null) return "Duplicate slot '$name'"
    slots[child.name] = child
    return null
  }

  Void dump(OutStream out := Env.cur.out, Str indent := "")
  {

    out.print(indent).printLine("XetoObj")
    if (name != null) out.print(indent).printLine("  name:  $name")
    if (type != null) out.print(indent).printLine("  type:  $type")
    if (doc != null)  out.print(indent).printLine("  doc:   $doc")
    if (val != null)  out.print(indent).printLine("  val:   $val")
    if (!meta.isEmpty)
    {
      out.print(indent).printLine("meta:")
      meta.each |x| { x.dump(out, indent+"  ") }
    }
    if (!slots.isEmpty)
    {
      out.print(indent).printLine("slots:")
      slots.each |x| { x.dump(out, indent+"  ") }
    }
  }

  private Str autoName(Bool isMeta)
  {
    map := isMeta ? meta : slots
    for (i := 0; i<1_000_000; ++i)
    {
      name := "_" + i.toStr
      if (map[name] == null) return name
    }
    throw Err("Too many children [$loc]")
  }

  private static Str:XetoObj newMap()
  {
    map := Str:Obj[:]
    map.ordered = true
    return map
  }

  private static const Str:XetoObj emptyMap := [:]
}

**************************************************************************
** XetoType
**************************************************************************

**
** Xeto type reference
**
@Js
class XetoType
{
  new makeSimple(FileLoc loc, Str name)
  {
    this.loc = loc
    this.name = name
  }

  new makeMaybe(FileLoc loc, Str name)
  {
    this.loc   = loc
    this.name  = name
    this.maybe = true
  }

  const FileLoc loc
  const Str name
  const Bool maybe

  override Str toStr() { name }
}

