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
** AST proto
**
internal class CProto
{
  new make(Loc loc, Str name, Str? doc := null, CType? type := null, Str? val := null)
  {
    this.loc      = loc
    this.name     = name
    this.doc      = doc
    this.type     = type
    this.val      = val
    this.children = noChildren
    this.asmRef   = AtomicRef()
  }

  Void each(|CProto| f) { children.each(f) }

  CProto? get(Str name, Bool checked := true)
  {
    kid := children.get(name, null)
    if (kid != null) return kid
    if (type != null) return type.deref.get(name, checked)
    if (checked) throw UnknownProtoErr(qname + "." + name)
    return null
  }

  CProto? getOwn(Str name, Bool checked := true)
  {
    kid := children.get(name, null)
    if (kid != null) return kid
    if (checked) throw UnknownProtoErr(qname + "." + name)
    return null
  }

  Bool isRoot() { parent == null }

  Str qname() { path.toStr }

  once Path path() { isRoot ? Path.root : parent.path.add(name) }

  once Bool isObj() { qname == "sys.Obj" }

  Bool fitsList() { fits("sys.List") }

  Bool fitsDict() { fits("sys.Dict") }

  Bool fits(Str qname)
  {
    if (this.qname == qname) return true
    if (type == null) return false
    return type.deref.fits(qname)
  }

  override Str toStr() { isRoot ? "_root_" : path.toStr }

  Bool isAssembled() { asmRef.val != null }

  MProto asm() { asmRef.val ?: throw Err("Not assembled yet [$name]") }

  static const Str:CProto noChildren := [:]

  Str assignName() { "_" + nameCounter++ }
  private Int nameCounter

  const Loc loc           // ctor
  const Str name          // ctor
  const AtomicRef asmRef  // Assemble.asm
  CPragma? pragma         // Parser
  CProto? parent          // Step.addSlot
  Str:CProto children     // Step.addSlot
  Str? doc                // ctor or Parser for suffix docs
  Str? val                // ctor or Parser
  CType? type             // Parser or Resolve
  Bool isLib              // Parse.parseLib
}

