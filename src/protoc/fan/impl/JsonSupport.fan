//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 Aug 2022  Brian Frank  Creation
//

using concurrent
using util
using proto

**
** JsonProtoEncoder
**
@Js
internal class JsonProtoEncoder : OutStream
{
  new make(OutStream out) : super(out) {}

  This encode(ProtoGraph pg)
  {
    printLine("{")
    kids := pg.root.listOwn
    kids.each |kid, i|
    {
      doEncode(kid, i + 1 < kids.size)
    }
    printLine("}")
    return this
  }

  private Void doEncode(Proto p, Bool comma)
  {
    kids := p.listOwn
    typeComma := kids.isEmpty && !p.hasVal ? "" : ","
    valComma := kids.isEmpty ? "" : ","

    indent.quoted(p.name).printLine(": {")

    indentation++

    if (p.type != null)
      indent.quoted("_type").print(": ").quoted(p.type.qname).printLine(typeComma)

    if (p.hasVal)
      indent.quoted("_val").print(": ").quoted(p.val).printLine(valComma)

    kids.each |kid, i|
    {
      doEncode(kid, i + 1 < kids.size)
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
** JsonProtoDecoder
**************************************************************************

**
** JsonProtoDecoder
**
@Js
internal class JsonProtoDecoder
{
  static ProtoGraph decode(InStream in)
  {
    try
    {
      decoder := make
      decoder.index(Path.root, JsonInStream(in).readJson)
      return decoder.asm
    }
    finally in.close
  }

  private JsonProto index(Path path, Str:Obj map)
  {
    x := JsonProto(path, map)
    acc[path.toStr] = x
    if (x.isLib) libs.add(path.toStr, x)
    map.each |v, k|
    {
      if (v is Map) x.children.add(index(path.add(k), v))
    }
    return x
  }

  private MProtoGraph asm()
  {
    root := asmProto(acc[""])
    libs := asmLibs
    return MProtoGraph(root, libs)
  }

  private MProto asmProto(JsonProto x)
  {
    if (x.isAssembled) return x.asm

    path    := x.path
    baseRef := AtomicRef()
    kids    := asmChildren(x.children)
    val     := x.map["_val"]

throw Err("TODO")

     m := x.isLib ?
       MProtoLib(FileLoc.unknown, path, baseRef, val, kids) :
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

  private Str:ProtoLib asmLibs()
  {
    libs.map |x->MProtoLib| { x.asm }
  }

  private Str:JsonProto acc := [:]
  private Str:JsonProto libs := [:]
}

**************************************************************************
** JsonProto
**************************************************************************

@Js
internal class JsonProto
{
  new make(Path path, Str:Obj map)
  {
    this.path   = path
    this.map   = map
    this.type  = map["_type"]
    this.isLib = type == "sys.Lib"
  }

  const Path path
  const Str? type
  const Bool isLib
  Str:Obj map
  JsonProto[] children := [,]

  Str name() { path.name }

  Bool isObj() { type == null }

  Bool isAssembled() { asmRef.val != null }
  MProto asm() { asmRef.val ?: throw Err("Not assembled yet [$path]") }
  const AtomicRef asmRef := AtomicRef()
}

