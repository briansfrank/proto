//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent

**
** Named reference to a proto
**
internal class CName
{
  new makeUnresolved(Loc loc, Str name) { this.loc = loc; this.name = name }

  new makeResolved(Loc loc, CProto c) { this.loc = loc; this.name = c.name; this.resolved = c }

  const Loc loc
  const Str name   // simple or dotted name

  Bool isResolved() { resolved != null }

  CProto deref() { resolved ?: throw Err("Not resolved yet: $name") }

  override Str toStr() { name }

  CProto? resolved  // Resolve step
}

