//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using concurrent
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
    if (x.isAssembled) return x.asm

    path    := x.path
    typeRef := x.isObj ? AtomicRef() : x.type.deref.asmRef
    kids    := x.children.map |kid->Proto| { asm(kid) }
    val     := x.val

    m := x.isLib ?
         MProtoLib(path, typeRef, val, kids) :
         MProto(path, typeRef, val, kids)

    x.asmRef.val = m
    return m
  }

  private Str:ProtoLib asmLibs()
  {
    acc := Str:ProtoLib[:]
    libs.each |x| { acc.add(x.path.toStr, (MProtoLib)x.proto.asm) }
    return acc
  }
}