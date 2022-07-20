//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jul 2022  Brian Frank  Creation
//

using proto

**
** Infer types from values and parent types
**
internal class Inherit : Step
{
  override Void run()
  {
    inherit(root)
  }

  private Void inherit(CProto p)
  {
    doInherit(p)
    p.each |kid| { inherit(kid) }
  }

  private Void doInherit(CProto p)
  {
    // walk up parent tree looking for the same object
    base := findBase(p.parent, p.name)
    if (base != null)
    {
      if (p.type == null)
        p.type = CName(p.loc, base)
      else
        echo("TODO: check $p.type fits $base")
    }
    else
    {
      // infer from value
      if (p.type == null && !p.isObj)
        p.type = CName(p.loc, infer(p))
    }
  }

  private CProto? findBase(CProto? p, Str name)
  {
    if (p == null || p.type == null) return null
    return p.type.deref.child(name)
  }

  private CProto infer(CProto p)
  {
    if (p.val is Str) return sys.str
    return sys.obj
  }

}

