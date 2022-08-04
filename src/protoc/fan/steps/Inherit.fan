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
        p.type = CType(p.loc, base)
      //else echo("TODO: check $p.type fits $base")
    }
    else
    {
      // infer from value
      if (p.type == null && !p.isObj)
        p.type = CType(p.loc, infer(p))
    }
  }

  private CProto? findBase(CProto? p, Str name)
  {
    if (p == null || p.type == null) return null
    return p.type.deref.getOwn(name, false)
  }

  private CProto infer(CProto p)
  {
    if (p.val is Str) return sys.str
    if (p.parent.fitsList)
    {
       of := inferParentOf(p, "sys.List._of")
       if (of != null) return of
    }
    if (p.parent.fitsDict)
    {
       of := inferParentOf(p, "sys.Dict._of")
       if (of != null) return of
    }
    return sys.dict
  }

  private CProto? inferParentOf(CProto p, Str rootOf)
  {
    of := p.parent.get("_of", false)
    if (of == null || of.type == null) return null
    if (of.qname == rootOf) return null
    return of.type.deref
  }

}

