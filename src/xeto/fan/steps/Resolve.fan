//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//   25 Jan 2023  Brian Frank  Redesign from proto
//

using util
using data

**
** Resolve all type refs
**
@Js
internal class Resolve : Step
{
  override Void run()
  {
echo("---> $compiler.qname $isLib")
    resolveDepends
    resolve(ast)
    bombIfErr
  }

  private Void resolveDepends()
  {
    // TODO decode dependencies from pragma
    pragma := ast.slots.get("pragma")?.meta?.get("depends")
    if (pragma == null) return
  }

  private Void resolve(XetoObj obj)
  {
    resolveType(obj.type)
    obj.each |kid| { resolve(kid) }
  }

  private Void resolveType(XetoType? type)
  {
    if (type == null) return
    if (type.isResolved) return

    name := type.name
    if (name.contains(".")) throw err("QNAME: $name", type.loc)

    // match to name within this AST which trumps depends
    type.inside = ast.slots[name]
    if (type.inside != null) return

    // match to external dependencies
    matches := DataType[,]
    depends.each |lib|
    {
      matches.addNotNull(lib.libType(name, false))
    }
    if (matches.isEmpty)
      err("Unresolved type: $name", type.loc)
    else if (matches.size > 1)
      err("Ambiguous type: $name $matches", type.loc)
    else
      type.outside = matches.first
  }

  private Str:DataLib depends := [:]
}