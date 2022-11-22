//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using concurrent
using util

**
** Named reference to a proto
**
internal class CType
{
  new makeUnresolved(FileLoc loc, Str name) { this.loc = loc; this.name = name }

  new makeResolved(FileLoc loc, CProto c) { this.loc = loc; this.name = c.name; this.resolved = c }

  const FileLoc loc
  const Str name   // simple or dotted name

  Bool isResolved() { resolved != null }

  CProto deref() { resolved ?: throw Err("Not resolved yet: $name") }

  override Str toStr() { name }

  CProto? resolved  // Resolve step
  Bool isMaybe      // Parse if names ends with question
}

