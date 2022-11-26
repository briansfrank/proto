//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using concurrent
using pog

**
** Assemble the AST into the implementation instances
**
internal class Assemble : Step
{

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    // assemble CProtos to MProtos
    root := asm(compiler.root)

    // assign base types
    assignBase(compiler.root)

    // create space implementation
    compiler.graph = MGraph(root, asmLibs)
  }

//////////////////////////////////////////////////////////////////////////
// Assemble
//////////////////////////////////////////////////////////////////////////

  private MProto asm(CProto x)
  {
    if (x.isAssembled) return x.asm

    path    := x.path
    baseRef := x.baseRef
    kids    := asmChildren(x.children)
    val     := x.val

    m := x.isLib ?
         MLib(x.loc, path, baseRef, val, kids) :
         MProto(x.loc, path, baseRef, val, kids)

    x.asmRef = m
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

  private Str:Lib asmLibs()
  {
    acc := Str:Lib[:]
    libs.each |x| { acc.add(x.path.toStr, (MLib)x.proto.asm) }
    return acc
  }

//////////////////////////////////////////////////////////////////////////
// Base Types
//////////////////////////////////////////////////////////////////////////

  private Void assignBase(CProto x)
  {
    x.baseRef.val = toBase(x)
    x.eachOwn |kid| { assignBase(kid) }
  }

  private MProtoBase toBase(CProto x)
  {
// TODO: validate And / OR has two or more in list
// TODO: we cannot allow OR if children with same name aren't compatible
    if (x.isObj) return MNullBase()
    if (x.type.deref.isAnd) return MAndBase(x.type.deref.asm, baseOfList(x))
    if (x.type.deref.isOr)  return MOrBase(x.type.deref.asm, baseOfList(x))
    return MSingleBase(x.type.deref.asm)
  }

  private MProto[] baseOfList(CProto x)
  {
    x.getOwn("_of").children.vals.map |kid->MProto| { kid.asm }
  }

}