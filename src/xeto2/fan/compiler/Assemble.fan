//
// Copyright (c) 2023, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Feb 2023  Brian Frank  Creation
//

using concurrent
using data2

**
** Assemble AST into implementation
**
@Js
internal class Assemble : Step
{
  override Void run()
  {
    emptyMetaRef = AtomicRef(env.emptyDict)

    // first pass creates slots
    compiler.lib = asmSpec(compiler.ast, compiler.qname, compiler.qname)

    // second pass for meta
    asmFinalize(compiler.ast)
  }

  private MSpec asmSpec(AObj obj, Str qname, Str name)
  {
    loc      := obj.loc
    libRef   := ast.asmRef
    baseRef  := asmBase(obj)
    metaRef  := asmMetaRef(obj)
    declared := asmDeclared(obj, qname)

    MSpec? spec
    if (obj.isLib)
      spec = MLib(env, loc, libRef, qname, name, baseRef, metaRef, declared)
    else if (obj.isType)
      spec = MType(env, loc, obj.asmRef, libRef, qname, name, baseRef, metaRef, declared, obj.val)
    else
      spec = MSpec(env, loc, obj.asmRef, baseRef, metaRef, declared, obj.val)

    obj.asmRef.val = spec
    return spec
  }

  private AtomicRef asmBase(AObj obj)
  {
    if (obj.type == null) return AtomicRef()  // sys::Obj
    return obj.type.resolved
  }

  private AtomicRef asmMetaRef(AObj obj)
  {
    if (obj.meta == null || obj.meta.isEmpty) return emptyMetaRef
    obj.metaRef = AtomicRef()
    return obj.metaRef
  }

  private Str:MSpec asmDeclared(AObj obj, Str qname)
  {
    slots := obj.slots
    if (slots == null || slots.isEmpty) return noDeclared
    acc := Str:MSpec[:]
    slots.each |kid|
    {
      name := kid.name
      sep := obj.isLib ? "::" : "."
      acc.add(name, asmSpec(kid, qname + sep + name, name))
    }
    return acc
  }

  private Void asmFinalize(AObj obj)
  {
    asmMeta(obj)

    if (obj.slots != null) obj.slots.each |kid| { asmFinalize(kid) }
  }

  private Void asmMeta(AObj obj)
  {
    // if metaRef null, then we used emptyDict ref
    if (obj.metaRef == null) return

    acc := Str:Obj[:]
    obj.meta.each |kid|
    {
      if (kid.val == null) return // TODO
      acc.add(kid.name, asmVal(kid.val))
    }
    obj.metaRef.val = env.dict(acc)
  }

  private Obj? asmVal(Obj val)
  {
    if (val is ARef) return ((ARef)val).resolved.val
    if (val is List)
    {
      list := (List)val
      if (list.of === ARef#) return list.map |x->DataSpec| { asmVal(x) }
      return list
    }
    return val
  }

  static const Str:MSpec noDeclared := [:]

  AtomicRef? emptyMetaRef
}