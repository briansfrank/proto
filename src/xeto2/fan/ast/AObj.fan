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
  new make(FileLoc loc, Obj? val := null)
  {
    this.loc = loc
    this.val = val
  }

  const FileLoc loc
  ASpecX spec := ASpecX()
  AMap slots := AMap()
  Obj? val
  Bool isLib
  Bool isType
  Bool isSpec

  const AtomicRef asmRef := AtomicRef()

  AtomicRef? metaRef

  Void dump(OutStream out := Env.cur.out, Str indent := "")
  {
    out.print(indent)
    if (spec.type != null) out.print(" ").print(spec.type)
    if (!spec.meta.isEmpty) spec.meta.dump(out, indent, "<>")
    if (val != null) out.print(" ").print(val.toStr.toCode)
    if (!slots.isEmpty) slots.dump(out, indent, "{}")
    out.printLine
  }

}