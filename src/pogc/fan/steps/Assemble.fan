//
// Copyright (c) 2022, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Jul 2022  Brian Frank  Creation
//

using concurrent
using pog
using pogSpi

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
    this.update = AssembleUpdate()
    this.update.execute |u->Graph|
    {
      // assemble CProtos to MProtos
      compiler.graph = asm(compiler.root)

      // assign base types
      assignBase(compiler.root)

      return compiler.graph
    }
  }

//////////////////////////////////////////////////////////////////////////
// Assemble
//////////////////////////////////////////////////////////////////////////

  private Proto asm(CProto x)
  {
    if (x.isAssembled) return x.asm

    path    := x.path
    baseRef := x.baseRef
    kids    := asmChildren(x.children)
    val     := x.val

    m := instantiate(x, MProtoSpi(x.loc, path, 0, baseRef, val, kids))

    x.asmRef = m
    return m
  }

  private Proto instantiate(CProto x, MProtoSpi spi)
  {
    update.spi = spi
    if (x.isLib) return Lib()
    if (x.isRoot) return MGraph(env, asmLibs)
    return Proto()
  }

  private Str:Proto asmChildren(Str:CProto children)
  {
    if (children.isEmpty) return MProtoSpi.noChildren
    acc := Str:Proto[:]
    acc.ordered = true
    children.each |kid| { acc.add(kid.name, asm(kid)) }
    return acc.toImmutable
  }

  private Str:Lib asmLibs()
  {
    acc := Str:Lib[:]
    libs.each |x| { acc.add(x.path.toStr, (Lib)x.proto.asm) }
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

  private Proto[] baseOfList(CProto x)
  {
    x.getOwn("_of").children.vals.map |kid->Proto| { kid.asm }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private AssembleUpdate? update

}

**************************************************************************
** AssembleUpdate
**************************************************************************

internal class AssembleUpdate : Update
{
  const override DateTime ts := DateTime.now

  const override Int ticks := Duration.nowTicks

  const override Int tx := 0

  MProtoSpi? spi

  override ProtoSpi init(Proto proto)
  {
    r := this.spi ?: throw Err("spi not ready")
    this.spi = null
    return r
  }

  override Graph graph() { throw err() }
  override ProtoStub clone(ProtoStub type) { throw err() }
  override This load(Str libName) { throw err() }
  override This unload(Str libName)  { throw err() }
  override This set(ProtoStub parent, Str name, Obj val) { throw err() }
  override This add(ProtoStub parent, Obj val, Str? name := null) { throw err() }
  override This remove(ProtoStub parent, Str name) { throw err() }
  override This clear(ProtoStub parent) { throw err() }
  override Void dump(OutStream out := Env.cur.out) { throw err() }
  Err err() { UnsupportedErr("AssembleUpdate") }
}