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
    return cx.toResult(Resolver(cx).resolve)
  }
}

**************************************************************************
** Resolver
**************************************************************************

@Js
internal class Resolver
{
  new make(TransduceContext cx)
  {
    this.cx   = cx
    this.ast  = cx.arg("ast") as Str:Obj ?: throw ArgErr("Expecting ast to be Str:Obj not [" + cx.arg("ast").typeof + "]")
    this.base = cx.arg("base", false) as Str ?: ""
  }

  Str:Obj resolve()
  {
    resolveDepends
    return resolveNode(ast)
  }

  Void resolveDepends()
  {
    // TODO
    if (base != "sys")
    {
      dependsGraph := cx.env.create(["sys"])
      depends = ["sys":dependsGraph.lib("sys")]
    }
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
    if (name.contains("."))
    {
      if (!resolveQualified(name)) cx.err("Unresolved qname '$name'", node)
      return name
    }

    matches := Str[,]

    // try my own AST
    mine := ast[name]
    if (mine != null) matches.add("${base}.${name}")

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
      cx.err("Ambiguous name '$name': $matches", node)
    return name
  }

  private Bool resolveQualified(Str qname)
  {
    dot := qname.indexr(".")
    libQName := qname[0..<dot]
    simpleName := qname[dot+1..-1]
    if (libQName == base)
    {
      return ast[simpleName] != null
    }
    depend := depends[libQName]
    return depend != null && depend.hasOwn(simpleName)
  }

  Proto? resolveInDepends(Str qname)
  {
    dot := qname.indexr(".")
    libQName := qname[0..<dot]
    simpleName := qname[dot+1..-1]
    return depends.get(libQName)?.getOwn(simpleName, false)
  }

  TransduceContext cx
  Str:Obj ast
  Str base
  Str:Lib depends := [:]
}