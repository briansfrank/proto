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

    // TODO
    dependsGraph := env.create(["sys"])
    depends := Str:Lib[:].addList(dependsGraph.libs) { it.name }

    ast = resolve(cx, depends, ast)
    return cx.toResult(ast)
  }

  private Obj? resolve(TransduceContext cx, Str:Lib depends, Str:Obj node)
  {
    node.map |v, n|
    {
      if (n == "_is") return resolveName(cx, depends, node, v)
      if (v is Map) return resolve(cx, depends, v)
      return v
    }
  }

  private Str resolveName(TransduceContext cx, Str:Lib depends, Str:Obj node, Str name)
  {
    if (name.contains(".")) return name

    matches := Proto[,]
    depends.each |depend|
    {
      matches.addNotNull(depend.getOwn(name, false))
    }

    if (matches.size == 1) return matches[0].qname.toStr

    if (matches.size == 0)
      cx.err("Unresolved name '$name'", node)
    else
      cx.err("ambiguous name '$name': $matches", node)
    return name
  }


}