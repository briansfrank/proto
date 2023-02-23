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
  Obj? val
  Str? doc
  Bool isLib

  const AtomicRef asmRef := AtomicRef()

  AtomicRef? metaRef

  Void addOf(XetoCompiler c, ARef of)
  {
    if (meta == null) meta = AMap(of.loc)
    x := AObj(of.loc)
    x.name = "of"
    x.val = of
    meta.add(c, x)
  }

  Void addOfs(XetoCompiler c, ARef[] ofs)
  {
    loc := ofs.first.loc
    if (meta == null) meta = AMap(loc)
    x := AObj(loc)
    x.name = "ofs"
    x.val = ofs
    meta.add(c, x)
  }

  Void dump(OutStream out := Env.cur.out, Str indent := "")
  {
    out.print(indent)
    if (name != null) out.print(name).print(":")
    if (type != null) out.print(" ").print(type)
    if (meta != null) meta.dump(out, indent, "<>")
    if (val != null) out.print(" ").print(val.toStr.toCode)
    if (slots != null) slots.dump(out, indent, "{}")
    out.printLine
  }

}