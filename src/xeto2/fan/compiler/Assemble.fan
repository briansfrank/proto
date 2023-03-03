//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Feb 2023  Brian Frank  Creation
//

using util
using data2

**
** Assemble AST into implementation
**
@Js
internal class Assemble : Step
{
  override Void run()
  {
    ast.walk |x| { asmNode(x) }
  }

  private Void asmNode(ANode x)
  {
    switch (x.nodeType)
    {
      case ANodeType.ref:    return asmRef(x)
      case ANodeType.scalar: return asmScalar(x)
      case ANodeType.val:    return asmVal(x)
      case ANodeType.spec:   return asmSpec(x)
      case ANodeType.type:   return asmType(x)
      case ANodeType.lib:    return asmLib(x)
      default: throw Err(x.nodeType.toStr)
    }
  }

  private Void asmRef(ARef x)
  {
    x.asm
  }

  private Void asmScalar(AScalar x)
  {
    if (x.isAsm) return
    x.val = x.str // TODO
  }

  private Void asmVal(AVal x)
  {
    // TODO: for now assume no val/slots is DataType ref
    if (x.val == null && x.slots == null)
    {
      if (x.type == null) throw err("wtf", x.loc)
      if (x.meta != null) throw err("wtf-2", x.loc)
      x.asmRef = x.type.asm
      return
    }

    if (x.val != null)
    {
      x.asmRef = x.val.asm
    }
    else
    {
      acc := Str:Obj[:]
      acc.ordered = true
      x.slots.each |obj, name| { acc[name] = obj.asm }
      x.asmRef = env.dict(acc)
    }
  }

  private Void asmLib(ALib x)
  {
    m := MLib(env, x.loc, x.qname, x.type.asm, asmMeta(x), asmSlots(x))
    mField->setConst(x.asm, m)
    mlField->setConst(x.asm, m)
  }

  private Void asmType(AType x)
  {
    m := MType(env, x.loc, x.lib.asm, x.qname, x.name, x.asm, x.base?.asm, asmMeta(x), asmSlots(x), x.val?.asm)
    mField->setConst(x.asm, m)
    mtField->setConst(x.asm, m)
  }

  private Void asmSpec(ASpec x)
  {
// TODO: need inference
if (x.type == null) x.type = sys.obj
    m := MSpec(env, x.loc, x.type.asm, asmMeta(x), asmSlots(x), x.val?.asm)
    mField->setConst(x.asm, m)
  }

  private DataDict asmMeta(ASpec x)
  {
    if (x.meta == null) return env.emptyDict
    asmVal(x.meta)
    return x.meta.asm
  }

  private MSlots asmSlots(ASpec x)
  {
    if (x.slots == null || x.slots.isEmpty) return MSlots.empty
    acc := Str:XetoSpec[:]
    acc.ordered = true
    x.slots.each |kid, name| { acc.add(name, kid.asm) }
    return MSlots(acc)
  }

  Field mField  := XetoSpec#m
  Field mtField := XetoType#mt
  Field mlField := XetoLib#ml
}