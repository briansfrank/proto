//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Jul 2022  Brian Frank  Creation
//

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

    pragma := p.pragma ?: throw Err("No pragma: $p")
    x := pragma.resolve(compiler, ref.name)
    if (x.size == 1)
      ref.resolved = x[0]
    else if (x.size == 0)
      err("Cannot resolve proto '$ref.name'", ref.loc)
    else
      err("Ambiguous proto name '$ref.name': $x", ref.loc)
  }
}

