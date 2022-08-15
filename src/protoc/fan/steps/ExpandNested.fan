//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Aug 2022  Brian Frank  Creation
//

using util

**
** Expand nested dotted names such as { foo.bar.baz: "value" }
**
internal class ExpandNested : Step
{
  override Void run()
  {
    checkExpand(root)
    bombIfErr
  }

  private Void checkExpand(CProto p)
  {
    p.children.dup.each |kid,  name|
    {
      if (name.contains("."))
        expand(p, name, kid)
      else
        checkExpand(kid)
    }
  }

  private Void expand(CProto parent, Str name, CProto kid)
  {
    parent.children.remove(name)
    names := name.split('.')
    names.eachRange(0..-2) |n|
    {
      x := parent.children[n]
      if (x == null)
      {
        x = CProto(kid.loc, n)
        addSlot(parent, x)
      }
      parent = x
    }
    addSlot(parent, CProto.makeRename(kid, names.last))
  }
}