//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Dec 2022  Brian Frank  Creation
//

using util
using pog

**
** Resolve transducer
**
@Js
const class ResolveTransducer : MTransducer
{
  new make(PogEnv env) : super(env, "resolve") {}

  override Str summary()
  {
    "Resolve unqualified names in an AST to qualified names"
  }

  override Str usage()
  {
    """Summary:
         Resolve unqualified names in an AST to qualified names.
       Usage:
         resolve ast:obj              Transform AST to AST
       Arguments:
         obj                          AST object tree
       """
  }

  override Obj? transduce(Str:Obj? args)
  {
    ast := arg(args, "ast")
    if (ast isnot Str:Obj) throw Err("Expecting Str:Obj map, not $ast [${ast?.typeof}]")

    // TODO
    dependsGraph := env.create(["sys"])
    depends := Str:Lib[:].addList(dependsGraph.libs) { it.name }

    return resolve(depends, ast)
  }

  private Obj? resolve(Str:Lib depends, Str:Obj node)
  {
    node.map |v, n|
    {
      if (n == "_is") return resolveName(depends, node, v)
      if (v is Map) return resolve(depends, v)
      return v
    }
  }

  private Str resolveName(Str:Lib depends, Str:Obj node, Str name)
  {
    if (name.contains(".")) return name

    matches := Proto[,]
    depends.each |depend|
    {
      matches.addNotNull(depend.getOwn(name, false))
    }

    if (matches.size == 1) return matches[0].qname.toStr

    if (matches.size == 0)
      err("Unresolved name '$name'", node)
    else
      err("ambiguous name '$name': $matches", node)
    return name
  }

  private Void err(Str msg, Str:Obj node)
  {
    // TODO
    throw FileLocErr(msg, astToLoc(node))
  }


}