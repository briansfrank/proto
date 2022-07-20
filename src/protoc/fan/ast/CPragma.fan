//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 2022  Brian Frank  Creation
//

using proto

**
** Pragma from a single source file
**
internal class CPragma
{
  new make(Loc loc, CLib lib) { this.loc = loc; this.lib = lib  }

  const Loc loc
  CLib lib

  CProto[] resolve(ProtoCompiler c, Str name)
  {
    x := cache[name]
    if (x != null) return x

    x = doResolve(c, name)
    cache[name] = x
    return x
  }

  private CProto[] doResolve(ProtoCompiler c, Str name)
  {
    name.contains(".") ? resolveQualified(c, name) : resolveUnqualified(c, name)
  }

  private CProto[] resolveQualified(ProtoCompiler c, Str name)
  {
    path := Path(name)
    CProto? p := c.root
    for (i := 0; i<path.size; ++i)
    {
      p = p.child(path[i])
      if (p == null) return CProto#.emptyList
    }
    return CProto[p]
  }

  private CProto[] resolveUnqualified(ProtoCompiler c, Str name)
  {
    acc := CProto[,]
    acc.addNotNull(lib.proto.child(name))
    lib.depends.each |depend|
    {
      acc.addNotNull(depend.proto.child(name))
    }
    return acc
  }

  private Str:CProto[] cache := Str:CProto[][:]
}

