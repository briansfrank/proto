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
const class ResolveTransducer : Transducer
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

  override Transduction transduce(Str:Obj? args)
  {
    cx := TransduceContext(this, args)
    ast := cx.arg("ast")
    if (ast isnot Str:Obj) throw Err("Expecting Str:Obj map, not $ast [${ast?.typeof}]")

    return cx.toResult(Resolver(cx, ast).resolve)
  }
}

**************************************************************************
** Resolver
**************************************************************************

@Js
internal class Resolver
{
  new make(TransduceContext cx, Str:Obj root)
  {
    this.cx = cx
    this.root = root
  }

  Str:Obj resolve()
  {
    resolveDepends
    return resolveNode(root)
  }

  private Void resolveDepends()
  {
    // TODO
    dependsGraph := cx.env.create(["sys"])
    depends = Str:Lib[:].addList(dependsGraph.libs) { it.name }
  }

  private Obj? resolveNode(Str:Obj node)
  {
    node.map |v, n|
    {
      if (n == "_is") return resolveName(node, v)
      if (v is Map) return resolveNode(v)
      return v
    }
  }

  private Str resolveName(Str:Obj node, Str name)
  {
    if (name.contains(".")) return name

    matches := Str[,]

    // try my own AST
    mine := root[name]
    if (mine != null) matches.add(".${name}")

    // try dependencies
    depends.each |depend|
    {
      p := depend.getOwn(name, false)
      if (p != null) matches.add(p.qname.toStr)
    }

    if (matches.size == 1) return matches[0]

    if (matches.size == 0)
      cx.err("Unresolved name '$name'", node)
    else
      cx.err("ambiguous name '$name': $matches", node)
    return name
  }

  private TransduceContext cx
  private Str:Lib depends := [:]
  private Str:Obj root
}