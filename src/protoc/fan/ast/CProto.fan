//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent

**
** AST proto
**
internal class CProto
{
  new make(Loc loc, Str name, Str? doc := null, CName? type := null, Str? val := null)
  {
    this.loc    = loc
    this.name   = name
    this.doc    = doc
    this.type   = type
    this.val    = val
  }

  const Loc loc
  const Str name
  Str? doc
  CProto? parent
  Str? val
  Str:CProto children := noChildren
  CName? type

  Void each(|CProto| f) { children.each(f) }

  CProto? child(Str name) { children.get(name, null) }

  // Assmemble step
  MProto asm() { asmRef ?: throw Err("Not assembled yet [$name]") }
  internal MProto? asmRef

  Bool isRoot() { parent == null }

  override Str toStr()
  {
    if (isRoot) return "__root__"
    if (parent.isRoot) return name
    return parent.toStr + "." + name
  }

  Bool isObj() { name == "Obj" && parent?.name == "lang" }

  static const Str:CProto noChildren := [:]
}

