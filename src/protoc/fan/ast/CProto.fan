//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto

**
** AST proto
**
internal class CProto
{
  new make(Loc loc, Str name, Str? doc := null, CName? type := null)
  {
    this.loc      = loc
    this.name     = name
    this.doc      = doc
    this.type     = type
    this.children = noChildren
  }

  Void each(|CProto| f) { children.each(f) }

  CProto? child(Str name) { children.get(name, null) }

  Bool isRoot() { parent == null }

  once Path path() { isRoot ? Path.root : parent.path.add(name) }

  override Str toStr() { isRoot ? "_root_" : path.toStr }

  Bool isObj() { name == "Obj" && parent?.name == "lang" }

  MProto asm() { asmRef ?: throw Err("Not assembled yet [$name]") }

  static const Str:CProto noChildren := [:]

  const Loc loc           // ctor
  const Str name          // ctor
  Str? doc                // ctor or Parser for suffix docs
  CProto? parent          // Step.addSlot
  Str:CProto children     // Step.addSlot
  Str? val                // Parser
  CName? type             // Parser or Resolve
  Bool isLib              // Parse.parseLib
  MProto? asmRef          // Assemble.asm
}

