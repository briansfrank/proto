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

  CProto? child(Str name) { children.get(name, null) }

  Bool isRoot() { parent == null }

  once Path path() { isRoot ? Path.root : parent.path.add(name) }

  once Bool isObj() { path.toStr == "sys.Obj" }

  override Str toStr() { isRoot ? "_root_" : path.toStr }

  Bool isAssembled() { asmRef.val != null }

  MProto asm() { asmRef.val ?: throw Err("Not assembled yet [$name]") }

  static const Str:CProto noChildren := [:]

  const Loc loc           // ctor
  const Str name          // ctor
  const AtomicRef asmRef  // Assemble.asm
  Int nameCounter         // Parser
  CPragma? pragma         // Parser
  CProto? parent          // Step.addSlot
  Str:CProto children     // Step.addSlot
  Str? doc                // ctor or Parser for suffix docs
  Str? val                // ctor or Parser
  CType? type             // Parser or Resolve
  Bool isLib              // Parse.parseLib
}

