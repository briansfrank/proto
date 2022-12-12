//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

using concurrent
using util
using pog
using pogSpi

**
** JSON representation of the AST
**
@Js
const class JsonAstPogIO : FilePogIO
{
  new make(PogEnv env) : super(env, "json-ast") {}

  override Str summary()
  {
    "JSON encoding of the AST"
  }

  override Graph readStream(InStream in)
  {
    JsonAstReader().readGraph(in)
  }

  override Void writeStream(Graph graph, OutStream out)
  {
    JsonAstWriter(out).writeGraph(graph)
  }
}

**************************************************************************
** JsonAstWriter
**************************************************************************

@Js
internal class JsonAstWriter : OutStream
{
  new make(OutStream out) : super(out) {}

  This writeGraph(Graph g)
  {
    printLine("{")
    kids := g.listOwn
    kids.each |kid, i|
    {
      writeProto(kid, i + 1 < kids.size)
    }
    printLine("}")
    return this
  }

  private Void writeProto(Proto p, Bool comma)
  {
    kids := p.listOwn
    typeComma := kids.isEmpty && !p.hasVal ? "" : ","
    valComma := kids.isEmpty ? "" : ","

    indent.quoted(p.name).printLine(": {")

    indentation++

    if (p.type != null)
      indent.quoted("_type").print(": ").quoted(p.type.qname.toStr).printLine(typeComma)

    if (p.hasVal)
      indent.quoted("_val").print(": ").quoted(p.val.toStr).printLine(valComma)

    kids.each |kid, i|
    {
      writeProto(kid, i + 1 < kids.size)
    }

    indentation--
    indent.print("}")
    if (comma) print(",")
    printLine
  }

  This quoted(Str s) { print(s.toCode) }

  This indent() { print(Str.spaces(indentation*2)) }

  Int indentation
}

**************************************************************************
** JsonAstReader
**************************************************************************

@Js
internal class JsonAstReader
{
  Graph readGraph(InStream in)
  {
    index(QName.root, JsonInStream(in).readJson)
    return asm
  }

  private JsonAstProto index(QName qname, Str:Obj map)
  {
    x := JsonAstProto(qname, map)
    acc[qname.toStr] = x
    if (x.isLib) libs.add(qname.toStr, x)
    map.each |v, k|
    {
      if (v is Map) x.children.add(index(qname.add(k), v))
    }
    return x
  }

  private Graph asm()
  {
    throw Err("TODO")
  }
    /*
    root := asmProto(acc[""])
    libs := asmLibs
    return MGraph(root, libs)
  }

  private Proto asmProto(JsonProto x)
  {
    if (x.isAssembled) return x.asm

    path    := x.path
    baseRef := AtomicRef()
    kids    := asmChildren(x.children)
    val     := x.map["_val"]

throw Err("TODO")

     m := x.isLib ?
       MLib(FileLoc.unknown, path, baseRef, val, kids) :
       MProto(FileLoc.unknown, path, baseRef, val, kids)

     x.asmRef.val = m
     return m
  }

  private Str:MProto asmChildren(JsonProto[] children)
  {
    if (children.isEmpty) return MProto.noChildren
    acc := Str:MProto[:]
    acc.ordered = true
    children.each |kid| { acc.add(kid.name, asmProto(kid)) }
    return acc.toImmutable
  }

  private Str:Lib asmLibs()
  {
    libs.map |x->Lib| { x.asm }
  }
  */

  private Str:JsonAstProto acc := [:]
  private Str:JsonAstProto libs := [:]
}

**************************************************************************
** JsonAstProto
**************************************************************************

@Js
internal class JsonAstProto
{
  new make(QName qname, Str:Obj map)
  {
    this.qname = qname
    this.map   = map
    this.type  = map["_type"]
    this.isLib = type == "sys.Lib"
  }

  const QName qname
  const Str? type
  const Bool isLib
  Str:Obj map
  JsonAstProto[] children := [,]

  Str name() { qname.name }

  Bool isObj() { type == null }

  Bool isAssembled() { asmRef.val != null }
  Proto asm() { asmRef.val ?: throw Err("Not assembled yet [$qname]") }
  const AtomicRef asmRef := AtomicRef()
}