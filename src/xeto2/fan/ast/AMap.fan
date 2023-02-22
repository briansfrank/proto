//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Jan 2023  Brian Frank  Creation
//

using util

**
** AST map of children objects (meta or slots)
**
@Js
internal class AMap
{
  new make(FileLoc loc)
  {
    this.loc = loc
    this.map = Str:AObj[:]
    this.map.ordered = true
  }

  Bool isEmpty() { map.isEmpty }

  Void add(XetoCompiler c, AObj child)
  {
    // auto-assign name if unnamed
    if (child.name == null) child.name = autoName
    name := child.name

    // report duplicate
    dup := map[name]
    if (dup != null)
    {
      c.err2("Duplicate name '$name'", dup.loc, child.loc)
      return
    }

    // add it
    map[name] = child
  }

  AObj? remove(Str name)
  {
    map.remove(name)
  }

  private Str autoName()
  {
    for (i := 0; i<1_000_000; ++i)
    {
      name := "_" + i.toStr
      if (map[name] == null) return name
    }
    throw Err("Too many children")
  }

  AObj? get(Str name) { map[name] }

  Void each(|AObj| f) { map.each(f) }

  Void dump(OutStream out, Str indent, Str brackets)
  {
    kidIndent := indent + "  "
    out.print(" ").printLine(brackets[0..0])
    map.each |kid| { kid.dump(out, kidIndent) }
    out.print(indent).print(brackets[1..1])
  }

  const FileLoc loc
  private Str:AObj map
}