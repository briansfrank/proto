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
  AMap meta := AMap()
  AMap slots := AMap()
  Obj? val
  Str? doc
  Bool isLib
  Bool isType

  const AtomicRef asmRef := AtomicRef()

  AtomicRef? metaRef

  Void setMeta(XetoCompiler c, AMap m)
  {
    if (meta.isEmpty)
    {
      meta = m
    }
    else
    {
      m.each |kid| { meta.add(c, kid) }
    }
  }

  Void addOf(XetoCompiler c, ARef of)
  {
    x := AObj(of.loc)
    x.name = "of"
    x.val = of
    meta.add(c, x)
  }

  Void addOfs(XetoCompiler c, ARef[] ofs)
  {
    loc := ofs.first.loc
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
    if (!meta.isEmpty) meta.dump(out, indent, "<>")
    if (val != null) out.print(" ").print(val.toStr.toCode)
    if (!slots.isEmpty) slots.dump(out, indent, "{}")
    out.printLine
  }

}