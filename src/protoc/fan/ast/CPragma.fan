//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto
using util

**
** Pragma from a single source file
**
internal class CPragma
{
  new make(FileLoc loc, CLib lib) { this.loc = loc; this.lib = lib  }

  const FileLoc loc
  CLib lib

  CProto[] resolve(Step step, Str name)
  {
    x := cache[name]
    if (x != null) return x

    x = doResolve(step, name)
    cache[name] = x
    return x
  }

  private CProto[] doResolve(Step step, Str name)
  {
    name.contains(".") ? resolveQualified(step, name) : resolveUnqualified(step, name)
  }

  private CProto[] resolveQualified(Step step, Str qname)
  {
    path := Path(qname)
    CProto? p := step.root
    for (i := 0; i<path.size; ++i)
    {
      name := path[i]

      // check own name
      x := p.getOwn(name, false)
      if (x == null)
      {
        // check if inherited, and if so we need to create
        // override in the parent as place holder with proper qname
        x = p.get(name, false)
        if (x != null)
          x = stubPath(step, p, x)
      }

      if (x == null) return CProto#.emptyList
      p = x
    }
    return CProto[p]
  }

  private CProto[] resolveUnqualified(Step step, Str name)
  {
    acc := CProto[,]
    acc.addNotNull(lib.proto.getOwn(name, false))
    lib.depends.each |depend|
    {
      acc.addNotNull(depend.proto.getOwn(name, false))
    }
    return acc
  }

  private CProto stubPath(Step step, CProto parent, CProto inherited)
  {
    child := CProto(FileLoc.synthetic, inherited.name, null, CType(FileLoc.synthetic, inherited), null)
    step.addSlot(parent, child)
    return child
  }

  private Str:CProto[] cache := Str:CProto[][:]
}

