//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using proto

**
** Assemble the AST into the implementation instances
**
internal class Assemble : Step
{
  override Void run()
  {
    compiler.ps = MProtoSpace(asm(compiler.root), asmLibs)
  }

  private MProto asm(CProto x)
  {
    path := x.path
    type := null // TODO
    kids := x.children.map |kid->Proto| { asm(kid) }
    val  := x.val

    m := x.isLib ?
         MProtoLib(path, type, val, kids) :
         MProto(path, type, val, kids)

    x.asmRef = m
    return m
  }

  private Str:ProtoLib asmLibs()
  {
    acc := Str:ProtoLib[:]
    libs.each |x| { acc.add(x.name.toStr, (MProtoLib)x.proto.asm) }
    return acc
  }
}