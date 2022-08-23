//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jul 2022  Brian Frank  Creation
//

using util
using proto

**
** Resolve all unresolved names in the AST
**
internal class ResolveNames : Step
{
  override Void run()
  {
    resolveProto(root)
    bombIfErr
  }

  private Void resolveProto(CProto p)
  {
    // resolve inherits
    if (p.type != null) resolve(p, p.type)

    // recurse
    p.each |kid| { resolveProto(kid) }
  }

  private Void resolve(CProto p, CType? ref)
  {
    if (ref == null || ref.isResolved) return

    // get pragma for proto's source file
    pragma := p.pragma ?: throw Err("No pragma: $p")

    // check pragma cache
    name := ref.name
    x := pragma.cache[name]
    if (x == null)
    {
      // lazily resolve and populate cache
      pragma.cache[name] = x = doResolve(pragma, name)
    }

    // resolve or report error
    if (x.size == 1)
      ref.resolved = x[0]
    else if (x.size == 0)
      err("Cannot resolve proto '$ref.name'", ref.loc)
    else
      err("Ambiguous proto name '$ref.name': $x", ref.loc)
  }

  private CProto[] doResolve(CPragma pragma, Str name)
  {
    name.contains(".") ? doResolveQualified(pragma, name) : doResolveUnqualified(pragma, name)
  }

  private CProto[] doResolveQualified(CPragma pragma, Str qname)
  {
    path := Path(qname)
    CProto? p := root
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
          x = stubPath(p, x)
      }

      if (x == null) return CProto#.emptyList
      p = x
    }
    return CProto[p]
  }

  private CProto[] doResolveUnqualified(CPragma pragma, Str name)
  {
    acc := CProto[,]
    acc.addNotNull(pragma.lib.proto.getOwn(name, false))
    pragma.lib.depends.each |depend|
    {
      acc.addNotNull(depend.proto.getOwn(name, false))
    }
    return acc
  }

  private CProto stubPath(CProto parent, CProto inherited)
  {
    child := CProto(FileLoc.synthetic, inherited.name, null, CType(FileLoc.synthetic, inherited), null)
    addSlot(parent, child)
    return child
  }
}

