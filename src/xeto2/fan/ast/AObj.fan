//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Jan 2023  Brian Frank  Creation
//

using concurrent
using util

**
** AST object - used to model both dicts and scalars
**
@Js
internal class AObj
{
  new make(FileLoc loc) { this.loc = loc }

  const FileLoc loc
  Str? name
  ARef? type
  AMap? meta
  AMap? slots
  Str? val
  Str? doc
  Bool isLib

  const AtomicRef asmRef := AtomicRef()

  Void dump(OutStream out := Env.cur.out, Str indent := "")
  {
    out.print(indent)
    if (name != null) out.print(name).print(":")
    if (type != null) out.print(" ").print(type)
    if (meta != null) meta.dump(out, indent, "<>")
    if (val != null) out.print(" ").print(val.toCode)
    if (slots != null) slots.dump(out, indent, "{}")
    out.printLine
  }

}