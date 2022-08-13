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
    kids    := asmChildren(x.children)
    val     := x.val

    m := x.isLib ?
         MProtoLib(x.loc, path, typeRef, val, kids) :
         MProto(x.loc, path, typeRef, val, kids)

    x.asmRef.val = m
    return m
  }

  private Str:MProto asmChildren(Str:CProto children)
  {
    if (children.isEmpty) return MProto.noChildren
    acc := Str:MProto[:]
    acc.ordered = true
    children.each |kid| { acc.add(kid.name, asm(kid)) }
    return acc.toImmutable
  }

  private Str:ProtoLib asmLibs()
  {
    acc := Str:ProtoLib[:]
    libs.each |x| { acc.add(x.path.toStr, (MProtoLib)x.proto.asm) }
    return acc
  }

}