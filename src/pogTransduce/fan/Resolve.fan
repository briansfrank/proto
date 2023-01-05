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
    "Resolve unqualified names in JSON AST to qualified names"
  }

  override Str usage()
  {
    """resolve <ast>                 Resolve JSON AST
       resolve <ast> base:<qname>    Resolve using given base qname
       """
  }

  override TransduceData transduce(Str:TransduceData args)
  {
    cx := TransduceContext(this, args)
    return Resolver(cx).resolve
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
    this.data = cx.argIt
    this.base = cx.base.toStr
    this.ast  = data.getAst
    this.loc  = data.loc
  }

  TransduceData resolve()
  {
    resolveDepends
    if (cx.isErr) return cx.toResult(ast, ["json", "ast", "unresolved"], loc)
    resolved := resolveNode(ast)
    return cx.toResult(resolved, ["json", "ast", "resolved"], loc)
  }

  Void resolveDepends()
  {
    // decode dependencies from pragma
    pragma := ast["pragma"] as Str:Obj
    depends := toDependNames(pragma)

    // make sure sys is specified unless this is sys itself
    if (!depends.any { it.qname == "sys" } && base != "sys")
      cx.err("Must specify 'sys' in depends", pragma ?: ast)

    // resolve each dependency
    depends.each |d|
    {
      lib := cx.env.load(d.qname, false)
      if (lib == null)
        cx.err("Cannot resolve dependency: $d.qname", d.loc)
      else
        this.depends.add(lib)
    }
  }

  private LibDepend[]? toDependNames([Str:Obj]? pragma)
  {
    // if no pragma, we always assume implicit dependency on sys
    if (pragma == null) return [LibDepend(cx.toLoc(ast), "sys")]

    // get _depends meta data
    depends := pragma["_depends"] as Str:Obj
    if (depends == null) return LibDepend[,]

    // map depends auto-names to dependency recs
    acc := LibDepend[,]
    depends.each |d, n|
    {
      // skip anything not _0, _1, etc
      if (!PogUtil.isAutoName(n)) return

      // object should be a Str:Obj
      map := d as Str:Obj
      if (map == null)
      {
        cx.err("Invalid depend dict", depends)
        return
      }

      // get the lib qname value
      loc := cx.toLoc(map)
      qname := (map["lib"] as Str:Obj)?.get("_val") as Str
      if (qname == null)
      {
        cx.err("Depend dict missing 'lib' qname: $map", loc)
        return
      }

      // accumulate to our dependency qname + loc recs
      acc.add(LibDepend(loc, qname))
    }
    return acc
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
      if (!isResolveQualified(name)) cx.err("Unresolved qname '$name'", node)
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

  private Bool isResolveQualified(Str qname)
  {
    // check if its under my base
    if (resolveInAst(qname) != null) return true

    // resolve in dependencies
    return resolveInDepends(qname) != null
  }

  [Str:Obj]? resolveInAst(Str qname)
  {
    if (!qnameIsUnder(base, qname)) return null
    path := qnamePathUnder(base, qname)
    [Str:Obj?]? node := ast
    for (i:=0; i<path.size; ++i)
    {
      node = node[path[i]]
      if (node == null) return null
    }
    return node
  }

  Proto? resolveInDepends(Str qname)
  {
    for (i:=0; i<depends.size; ++i)
    {
      proto := resolveInDepend(depends[i], qname)
      if (proto != null) return proto
    }
    return null
  }

  private Proto? resolveInDepend(Lib lib, Str qname)
  {
    if (!qnameIsUnder(lib.qname.toStr, qname)) return null
    path := qnamePathUnder(lib.qname.toStr, qname)
    Proto? proto := lib
    for (i:=0; i<path.size; ++i)
    {
      proto = proto.getOwn(path[i], false)
      if (proto == null) return null
    }
    return proto
  }

  private Bool qnameIsUnder(Str base, Str qname)
  {
    qname.startsWith(base) && qname.size >= base.size+2 && qname[base.size] == '.'
  }

  private Str[] qnamePathUnder(Str base, Str qname)
  {
    qname[base.size+1..-1].split('.')
  }

  TransduceContext cx
  TransduceData data
  FileLoc loc
  Str:Obj? ast
  Str base
  Lib[] depends := [,]
}

**************************************************************************
** LibDepend
**************************************************************************

@Js
internal const class LibDepend
{
  new make(FileLoc loc, Str qname) { this.loc = loc; this.qname = qname }
  const FileLoc loc
  const Str qname
  override Str toStr() { qname }
}