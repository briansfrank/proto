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
    // TODO
    path := Path.fromStr(name)
    acc := CProto[,]
    acc.addNotNull(doResolveIn(c.root, path))
    acc.addNotNull(doResolveIn(c.root, Path("sys", name)))
    /*
    c.depends.each |depend|
    {
      acc.addNotNull(doResolveIn(depend as IProto, path))
    }
    */
    return acc
  }

  private CProto? doResolveIn(CProto? root, Path path)
  {
    p := root
    for (i := 0; i<path.size; ++i)
    {
      p = p.child(path[i])
      if (p == null) return null
    }
    return p
  }

  private Str:CProto[] cache := Str:CProto[][:]
}

