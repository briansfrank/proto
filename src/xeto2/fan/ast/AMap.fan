//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Jan 2023  Brian Frank  Creation
//

using util

**
** AST map of name/value pairs - dict, spec meta, or spec slots
**
@Js
internal class AMap
{

  Bool isEmpty() { map.isEmpty }

  Void add(XetoCompiler c, Str? name, AObj child)
  {
    if (map.isEmpty)
    {
      map = Str:AObj[:]
      map.ordered = true
    }

    // auto-assign name if unnamed
    if (name == null) name = autoName

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
    if (map.isEmpty) return null
    return map.remove(name)
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

  Void each(|AObj, Str| f) { map.each(f) }

  Void dump(OutStream out, Str indent, Str brackets)
  {
    kidIndent := indent + "  "
    out.print(" ").printLine(brackets[0..0])
    map.each |kid| { kid.dump(out, kidIndent) }
    out.print(indent).print(brackets[1..1])
  }

  override Str toStr()
  {
    s := StrBuf()
    map.each |v, n|
    {
      if (s.size > 1) s.add(", ")
      s.add(n).add(": $v.val")
    }
    return s.toStr
  }

  static const Str:AObj empty := [:]

  private Str:AObj map := empty
}